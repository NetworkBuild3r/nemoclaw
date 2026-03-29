# Archivist MCP -- tool summary

Condensed from `archivist-oss/docs/CURSOR_SKILL.md` and fleet `AGENTS.md`. For full parameter lists, read the upstream doc in-repo.

## Search & Retrieval

| Tool | Purpose |
|------|---------|
| `archivist_search` | Semantic search + 10-stage RLM pipeline with optional LLM refinement, tier selection, date filters, multi-agent fleet support |
| `archivist_recall` | Entity-centric multi-hop graph lookup (entities, relationships, facts) |
| `archivist_timeline` | Chronological slice for a topic with configurable lookback |
| `archivist_insights` | Cross-agent topic discovery across accessible namespaces |
| `archivist_deref` | Dereference a memory by ID for full L2 detail (drill-down after L0/L1 search) |
| `archivist_index` | Compressed navigational index of namespace knowledge (~500 tokens) |
| `archivist_contradictions` | Surface contradicting facts about an entity across agents |

## Storage & Memory Management

| Tool | Purpose |
|------|---------|
| `archivist_store` | Write a memory with entity extraction, conflict checks, LLM dedup |
| `archivist_merge` | Merge conflicting entries (latest / concat / semantic / manual) |
| `archivist_compress` | Archive memories and return compact summaries (flat or structured Goal/Progress/Decisions/Next Steps) |

## Trajectory & Feedback

| Tool | Purpose |
|------|---------|
| `archivist_log_trajectory` | Log execution trajectory (task + actions + outcome), auto-extract tips |
| `archivist_annotate` | Add quality annotations (note, correction, stale, verified, quality) to a memory |
| `archivist_rate` | Rate a memory as helpful (+1) or unhelpful (-1) |
| `archivist_tips` | Retrieve strategy/recovery/optimization tips from past trajectories |
| `archivist_session_end` | Summarize a session into durable memory |

## Skill Registry

| Tool | Purpose |
|------|---------|
| `archivist_register_skill` | Register or update a skill (MCP tool) with provider, version, endpoint |
| `archivist_skill_event` | Log invocation outcome (success/partial/failure) for health scoring |
| `archivist_skill_lesson` | Record failure modes, workarounds, best practices |
| `archivist_skill_health` | Get health grade, success rate, recent failures, substitutes |
| `archivist_skill_relate` | Create relations between skills (similar_to, depend_on, compose_with, replaced_by) |
| `archivist_skill_dependencies` | Get skill dependency/relation graph |

## Admin & Context Management

| Tool | Purpose |
|------|---------|
| `archivist_context_check` | Pre-reasoning token counting against a budget with compaction hints |
| `archivist_namespaces` | List namespaces visible to an agent |
| `archivist_audit_trail` | View immutable audit log entries |
| `archivist_resolve_uri` | Resolve `archivist://` URIs to their underlying resource |
| `archivist_retrieval_logs` | Export/analyze retrieval pipeline execution traces |
| `archivist_health_dashboard` | Single-pane health: memory counts, stale %, conflict rate, skills, cache |
| `archivist_batch_heuristic` | Recommended batch size (1-10) from health signals |

## Cache Management

| Tool | Purpose |
|------|---------|
| `archivist_cache_stats` | Hot cache stats (entries per agent, TTL, hit rate) |
| `archivist_cache_invalidate` | Manual eviction by namespace, agent, or all |

## NemoClaw fleet -- agent_id and namespace (from AGENTS.md)

| OpenClaw agent id | Role | Typical `namespace` for Archivist |
|-------------------|------|-----------------------------------|
| `chief` | Coordinator | `chief` |
| `gitbob` | GitLab/Git | `pipeline` |
| `kubekate` | Kate — K8s + Argo CD | `deployer` |
| `kubekate` | Kubernetes | `deployer` |
| `grafgreg` | Grafana | `pipeline` |

Use the **OpenClaw agent id** (`chief`, `gitbob`, ...) as `agent_id` when storing unless your integration uses a different id string -- match the runtime's `agentId`.

## Hints

- `min_score` / `RETRIEVAL_THRESHOLD`: use `0` to disable score filtering for a single call when debugging recall.
- Prefer `archivist_search` first; refine with `archivist_recall` when entities are known.
- Use `archivist_context_check` before reasoning to decide if context compaction is needed.
- Use `archivist_compress` with `format: structured` for Goal/Progress/Decisions/Next Steps summaries.
- Log trajectories so future searches benefit from outcome-aware retrieval scoring.
