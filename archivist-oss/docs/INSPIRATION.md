# Inspiration & Build Reference

This document tracks external projects that influenced Archivist-OSS design
decisions, what we adopted, what we deliberately chose not to adopt, and the
rationale behind each change.

---

## ReMe (agentscope-ai/ReMe)

**Repository:** https://github.com/agentscope-ai/ReMe
**Reviewed:** 2026-03-21
**What it is:** A memory management toolkit for AI agents with two systems:
a file-based memory system (ReMeLight) and a vector-based memory system
with personal, procedural, and tool memory types.

### What we learned

ReMe tackles two problems Archivist originally didn't address directly:
**limited context windows** (early information lost in long conversations)
and **stateless sessions** (new sessions can't inherit history).

Their "memory as files" philosophy (MEMORY.md, daily journals, raw dialog
JSONL) makes memory human-readable and debuggable — a stark contrast to
Archivist's Qdrant-only long-term storage.

### Strengths we don't have (yet)

| Capability | ReMe approach | Archivist status |
|---|---|---|
| Context window management | `check_context()` with token counting, reserve-from-tail, message splitting | ✅ `archivist_context_check` MCP tool (v1.1) |
| Conversation compaction | `compact_memory()` produces structured summaries (Goal/Progress/Decisions/Next Steps/Critical Context) | ✅ `archivist_compress` supports `format=structured` (v1.1) |
| Pre-reasoning hook | `pre_reasoning_hook()` runs before every agent step: compact tools, check context, compact if needed, persist async | No equivalent — agent-side hook planned for OpenClaw |
| BM25 / keyword search | Vector (0.7) + BM25 (0.3) weighted hybrid retrieval | ✅ FTS5 hybrid search (v1.2) — same 0.7/0.3 weights, SQLite FTS5 |
| Token counting | Model-specific via tiktoken with `chars//4` fallback | ✅ `tokenizer.py` with tiktoken + fallback (v1.1) |
| Tool result compaction | Detects long outputs, truncates, stores full in file, keeps reference | Not implemented |
| Session-level memory | `ReMeInMemoryMemory` with `estimate_tokens()` and JSONL persistence | No in-session memory management |
| Formal benchmarks | LoCoMo (86.23 overall), HaluMem (88.78 QA accuracy) | No benchmark results yet |

### Strengths we already have that ReMe lacks

| Capability | Archivist | ReMe |
|---|---|---|
| Multi-agent fleet with RBAC | Namespace-based access control, team mapping, per-agent filtering | Single-user only, no ACL |
| Knowledge graph | SQLite entities/relationships/facts with multi-hop traversal | No structured knowledge |
| 10-stage retrieval pipeline (RLM) | Vector + graph + temporal decay + hotness + rerank + refinement + synthesis | Flat vector + BM25 fusion |
| MCP protocol | Language-agnostic MCP over HTTP SSE — any framework can use it | Python-only API |
| Background curation | Autonomous LLM entity/fact extraction from memories | No background processing |
| Observability | Prometheus metrics, retrieval logs, health dashboard, batch heuristic | None |
| Skill registry & trajectory | Structured learning from execution patterns, tips, ratings | No equivalent |
| Hierarchical chunking | Parent/child with L0/L1/L2 tiered context | Flat chunking only |

### Design decisions

**Why we keep MCP instead of adopting ReMe's Python API:**
Archivist serves a fleet of agents that may be implemented in different
languages and frameworks. MCP over HTTP SSE is the right abstraction for
a shared memory service. ReMe's tight Python integration makes sense for
single-agent use but doesn't scale to fleet architectures.

**Why context management belongs in the agent loop, not in Archivist:**
Archivist is a memory *service* (store, index, retrieve). Context window
management is an *agent-side* concern. The plan is to expose
`archivist_context_check` and `archivist_compact` as MCP tools, but the
actual pre-reasoning hook should live in the agent framework (OpenClaw).

**Why we're choosing SQLite FTS5 over rank_bm25 for hybrid search:**
Archivist already uses SQLite for the knowledge graph, audit logs, skills,
and trajectory. Adding FTS5 tables keeps the stack simple — no new
dependencies, persistent index, same filtering as graph queries, and no
RAM pressure from loading the full corpus into memory.

---

## Changes from v1.0.0 (ReMe-inspired)

### v1.0.1 — Bug fixes and hardening

These fixes were identified during the ReMe comparison code review.

#### Fix: `curator.py` `decay_old_entries()` used `conn.total_changes`

`conn.total_changes` returns the cumulative row count for the connection
lifetime, not the rows affected by the last statement. This caused inflated
counts in the decay log message. If `get_db()` ever returned a reused
connection, it would also include mutations from prior operations.

**Before:** `affected = conn.total_changes`
**After:** `affected = cur.rowcount` (rows affected by the UPDATE only)

#### Fix: Background tasks in `main.py` were fire-and-forget

Four `asyncio.create_task()` calls in `startup()` dropped the task
references immediately. If a task crashed with an unhandled exception,
it was silently garbage-collected with no log output.

**Fix:** Task references are now stored in `_background_tasks`. Each task
gets a descriptive `name=` and a `done_callback` that logs exceptions
via `logger.exception()`. Task names are logged at startup for visibility.

Same pattern applied to `webhooks.py` `fire_background()`: task references
are held in a `_pending_fires` set and auto-discarded on completion, so
they are not GC'd before the webhook HTTP call finishes.

#### Refactor: Split monolithic `mcp_server.py` into domain modules

The original `mcp_server.py` was 1,694 lines containing all 29 tool
definitions, a 58-branch if/elif dispatch chain, and 28 handler functions.
This made it the single hardest file to navigate, review, or extend.

**Approach:** Created a `src/handlers/` package with 8 files (originally
named `src/mcp/`, renamed to avoid shadowing the pip `mcp` package):

| File | Responsibility | Tools |
|---|---|---|
| `_common.py` | `_rbac_gate()`, `error_response()`, `success_response()` | -- |
| `_registry.py` | `TOOL_REGISTRY` dict, `get_all_tools()`, `dispatch_tool()` | -- |
| `tools_search.py` | Core retrieval | 7 (search, recall, timeline, insights, deref, index, contradictions) |
| `tools_storage.py` | Memory write path | 3 (store, merge, compress) |
| `tools_trajectory.py` | Execution learning | 5 (log_trajectory, annotate, rate, tips, session_end) |
| `tools_skills.py` | Skill registry | 6 (register, event, lesson, health, relate, dependencies) |
| `tools_admin.py` | Ops and admin | 6 (namespaces, audit_trail, resolve_uri, retrieval_logs, health_dashboard, batch_heuristic) |
| `tools_cache.py` | Hot cache control | 2 (cache_stats, cache_invalidate) |

Each domain module exports `TOOLS` (list of `Tool`) and `HANDLERS` (dict
mapping tool name to async handler). The registry aggregates them and
replaces the if/elif chain with a single `dict.get()` lookup.

`mcp_server.py` is now ~30 lines: creates the MCP `Server`, wires
`list_tools()` and `call_tool()` to the registry.

**Cross-module dependencies handled via imports:**
- `tools_trajectory._handle_session_end` imports `_handle_store` from
  `tools_storage` (stores session summaries as durable memories).
- `tools_admin._handle_resolve_uri` imports `_handle_deref`, `_handle_recall`,
  and `_handle_index` from `tools_search` (delegates URI resolution).

**Why not a plugin/auto-discovery system:** The 29 tools are stable and
co-deployed. Explicit imports are simpler, type-safe, and grep-friendly.
Plugin discovery adds complexity for a problem we don't have.

#### Fix: Dockerfile ran as root

The container ran as UID 0 with no `USER` directive. This is a security
anti-pattern — a container escape would grant root on the host.

**Fix:** Added `addgroup`/`adduser` for a non-root `archivist` user
(default UID/GID 1000, overridable via `--build-arg UID=` / `GID=`).
Data directories (`/data/archivist`, `/data/memories`) are created and
chowned during build. Volume mounts must be writable by the container UID.

---

### v1.1.0 — Context window management & structured compaction

These features were directly inspired by ReMe's `check_context()` and
`compact_memory()`. Archivist's implementation adapts the concepts for a
fleet-oriented memory service exposed over MCP.

#### New module: `tokenizer.py`

Lazy-loads tiktoken (cl100k_base encoding) when available, falling back
to `chars // 4`. Provides `count_tokens(text)` for single strings and
`count_message_tokens(messages)` for OpenAI-style chat message lists
(including ~4 tokens per-message overhead and 2-token reply priming).

tiktoken is listed as an optional dependency in `requirements.txt`.

**Why cl100k_base:** It covers GPT-4o, GPT-4, and GPT-3.5-turbo. Since
Archivist talks to OpenAI-compatible endpoints via LiteLLM, this is the
most broadly applicable encoding. The fallback ensures zero-dependency
deployments still work with acceptable accuracy.

#### New module: `context_manager.py`

Provides `check_context(messages, budget_tokens, reserve_from_tail)`
which analyzes a chat message list:
- Counts total tokens via the tokenizer
- Computes budget usage percentage
- Returns a hint: `"ok"` (≤70%), `"compress"` (70-90%), `"critical"` (>90%)
- When over budget, identifies a split point that preserves the most
  recent `reserve_from_tail` tokens, recommending how many older messages
  should be compacted

Also provides `check_memories_budget(memory_texts, budget_tokens)` for
simpler memory-text-only budget checks.

**Design choice — split index:** When splitting, we walk backwards from
the tail accumulating tokens until the reserve is met, then avoid breaking
user/assistant pairs. This mirrors ReMe's `reserve_from_tail` parameter
but doesn't require the agent to manage message indices.

#### New module: `compaction.py`

Two compaction modes:

1. **Structured** (`compact_structured`): LLM produces a JSON object
   with `goal`, `progress`, `decisions`, `next_steps`, `critical_context`.
   Supports incremental compaction via `previous_summary` parameter — the
   prior structured summary is prepended so the LLM can merge old and new.

2. **Flat** (`compact_flat`): Single-paragraph summary (the original
   `archivist_compress` behavior, now extracted into a shared module).

`format_structured_summary()` renders the JSON as readable markdown for
storage as a memory entry.

**Why JSON mode:** We request `json_mode=True` from the LLM for structured
output, with a fallback to flat compaction if JSON parsing fails. This
mirrors ReMe's structured output approach but with graceful degradation.

#### New MCP tool: `archivist_context_check`

Added to `tools_admin.py`. Accepts either `messages` (chat messages) or
`memory_texts` (raw strings) and returns token counts, budget usage, and
compaction hints. Agents call this as a pre-reasoning check to decide
whether to invoke `archivist_compress`.

No RBAC required — context checking is a stateless utility operation.

#### Upgraded: `archivist_compress` — structured format support

New optional parameters:
- `format`: `"flat"` (default) or `"structured"` (Goal/Progress/Decisions/Next Steps)
- `previous_summary`: Prior structured JSON for incremental compaction

The handler now delegates to `compaction.compact_structured()` or
`compaction.compact_flat()` instead of inline LLM calls. Structured
results include the full `structured_summary` dict in the response.

#### Upgraded: `rlm_retriever.py` — proper token counting

Replaced all `len(text) // 4` heuristics in the retriever's budget cap
and context-status signaling with `tokenizer.count_tokens()`. This gives
accurate counts when tiktoken is installed and identical behavior when
it's not.

#### New config: `DEFAULT_CONTEXT_BUDGET`

`DEFAULT_CONTEXT_BUDGET` env var (default 128000) sets the fallback token
budget for `archivist_context_check` when the caller doesn't specify one.

---

### v1.2.0 — BM25/FTS5 hybrid search

ReMe uses `rank_bm25` (in-memory BM25 scoring over the full corpus) fused
with vector similarity at a 0.7 vector / 0.3 BM25 weight split. We adopted
the same weight ratio but chose SQLite FTS5 as the implementation.

#### Why FTS5 over rank_bm25

- Archivist already uses SQLite for the knowledge graph, audit logs, skills,
  and trajectory. FTS5 is a built-in extension — zero new dependencies.
- The index is persistent. `rank_bm25` requires loading all chunk texts into
  RAM on startup and re-fitting on every new document. FTS5 updates are
  single-row INSERT/DELETE operations synced at index time.
- FTS5 supports the same column filters (namespace, agent_id, memory_type)
  we use in Qdrant, so filtered hybrid search works without post-filtering.
- Porter stemming (`tokenize='porter unicode61'`) gives us morphological
  matching (e.g. "deploying" matches "deployment") for free.

#### Schema: `memory_chunks` + `memory_fts`

`memory_chunks` is a regular table mirroring the Qdrant payload fields
needed for filtering. `memory_fts` is a content-sync FTS5 virtual table
that reads its text from `memory_chunks.text` via `content_rowid`.

Both tables are created in `graph.init_schema()`. The FTS5 table is
initialized in a separate `_init_fts5()` call because FTS5 DDL requires
different error handling than regular tables.

#### Write path: dual-write to Qdrant + FTS5

`indexer.index_file()` now calls `graph.upsert_fts_chunk()` for each
point after the Qdrant upsert, when `BM25_ENABLED` is true. The same
happens in `tools_storage._handle_store()` for API-based memory writes.

`indexer.delete_file_points()` calls `graph.delete_fts_chunks_by_file()`
to clean up the FTS5 index when files are removed.

#### Read path: `fts_search.py` + retriever fusion

New `fts_search.py` module:

- `search_bm25()`: wraps `graph.search_fts()` with query sanitization
  (`_fts5_safe_query` wraps each token in quotes to prevent FTS5 syntax
  errors from natural language queries containing AND/OR/NOT/colons).
- `merge_vector_and_bm25()`: normalizes both score sets to [0, 1] then
  applies `VECTOR_WEIGHT * norm_vector + BM25_WEIGHT * norm_bm25`. Results
  are deduped on `qdrant_id` with fused scores, then sorted descending.

#### Pipeline insertion point

In `rlm_retriever.recursive_retrieve()`, BM25 search runs as
"Stage 1-bm25" immediately after Stage 1 (vector search) and before
Stage 1a (graph augmentation). This is before dedup, temporal decay,
threshold filtering, and reranking — so the full pipeline still applies
to the fused results.

The `retrieval_trace` dict now includes `bm25_enabled` and `bm25_hits`
fields for observability.

#### Config

Three new env vars:
- `BM25_ENABLED` (default `true`) — toggle hybrid search
- `BM25_WEIGHT` (default `0.3`) — keyword score weight
- `VECTOR_WEIGHT` (default `0.7`) — vector score weight

---

### v1.3.0 — Curator improvements

Three targeted improvements to the autonomous curator.

#### 5a. Content checksum guard

**Problem:** `curate_cycle()` used only mtime to decide which files to
reprocess. Any metadata-only change (permissions, `touch`, editor save
without edits) triggered full LLM extraction + re-indexing — expensive
and wasteful.

**Fix:** After reading a file, compute `sha256(content)` and compare
against the stored checksum in `curator_state` (`checksum:{rel_path}`).
If the content hasn't changed, skip extraction and indexing entirely.
The checksum is written to `curator_state` only after successful
processing, so interrupted cycles re-process the file on the next run.

The mtime check is still the first filter (fast filesystem stat), so
files that haven't been touched at all are skipped before even reading
the content. The checksum is the second filter for files that pass
mtime but have identical content.

#### 5b. N-gram entity extraction

**Problem:** `extract_entity_mentions()` split the query on spaces and
searched each word individually (minimum 3 chars). This missed:
- Multi-word entities: "Argo CD", "hot cache", "knowledge graph"
- Short entities: "K8s", "AI", "CI" (under 3-char threshold)
- Compound names: "Batch Size Gravity", "GitOps pipeline"

**Fix:** N-gram expansion — try 3-word, 2-word, then 1-word windows
against the entity table. Longer phrases are tried first so "Argo CD"
is matched as a single entity rather than two separate hits on "argo"
and "cd". The minimum phrase length is reduced to 2 characters to catch
short but valid entity names.

This is the "low-cost improvement" from the plan. The more expensive
LLM-based entity extraction remains a future option for queries where
N-grams still miss (e.g. "How do I deploy?" → entity "deployment pipeline").

#### 5c. Curator loop backoff

**Problem:** `curator_loop()` used a fixed sleep of
`CURATOR_INTERVAL_MINUTES * 60` regardless of whether the cycle
succeeded or failed. A persistent failure (e.g. LLM endpoint down,
SQLite locked) would hammer the failing service every interval.

**Fix:** Exponential backoff on failure (double the interval, capped at
1 hour), reset to base interval on success. This reduces load on failing
dependencies while preserving normal cycle timing when healthy.

---

## Planned improvements (from ReMe comparison)

These items are tracked in the Cursor plan `archivist_vs_reme_review`.

- ~~**Context window management**~~ — Done in v1.1.0.
- ~~**Structured compaction**~~ — Done in v1.1.0.
- ~~**BM25 hybrid search**~~ — Done in v1.2.0.
- ~~**MCP server refactor**~~ — Done in v1.0.1.
- ~~**Curator checksum guards**~~ — Done in v1.3.0.
- ~~**Entity extraction improvement**~~ — Done in v1.3.0.
- ~~**Documentation update**~~ — Done in v1.4.0. All 30 tools documented.
- ~~**Test coverage**~~ — Done in v1.4.0. pytest infrastructure + 55 new tests.

- ~~**Human-readable journal exports**~~ — Done in v1.5.0. Daily markdown files alongside Qdrant.

All items from the original ReMe comparison review have been addressed.
