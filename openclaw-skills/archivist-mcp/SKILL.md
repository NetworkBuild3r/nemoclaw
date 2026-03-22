---
name: archivist-mcp
description: Use Archivist-OSS MCP tools (search, recall, store, compress, context_check, skills, trajectories, cache, admin) with correct RBAC agent_id and namespace fields. Use when calling Archivist from an agent, debugging memory retrieval, or aligning with fleet RBAC.
metadata: {"openclaw":{}}
---

# Goal

Use **Archivist** MCP tools correctly: right endpoints, parameters, and **per-agent** `agent_id` / `namespace` conventions for the NemoClaw fleet. Archivist exposes **30 tools** across 6 domains.

## When to Use

- Implementing or debugging any `archivist_*` tool call.
- Explaining RBAC, namespaces, or cross-agent search (`caller_agent_id`, `agent_ids`).
- Choosing between search, recall, store, compress, context_check, or skill tools.
- Managing context windows or compacting conversations.

## Instructions

1. **Transport:** Archivist exposes MCP over **HTTP SSE**. Typical endpoints:
   - SSE: `http://<archivist-host>:<port>/mcp/sse`
   - Messages: `http://<archivist-host>:<port>/mcp/messages/`
   The host/port come from deployment (`config/mcporter.json` -> `archivist.url` in this repo's layout).
2. **Search (7 tools):** `archivist_search` is the default for semantic Q&A; set `refine: false` for lower latency. Use `tier: l0` with `max_tokens` for lightweight context injection. `archivist_recall` for entity-centric graph lookup. `archivist_timeline`, `archivist_insights`, `archivist_deref`, `archivist_index`, `archivist_contradictions` for specialized retrieval.
3. **Storage (3 tools):** `archivist_store` with `agent_id` (required) and optional `namespace`, `entities`, `importance_score`, `memory_type`. `archivist_merge` for conflicts. `archivist_compress` with `format: structured` for Goal/Progress/Decisions/Next Steps summaries.
4. **Context management:** Use `archivist_context_check` before reasoning to check token budget usage. If hint is `compress`, call `archivist_compress` to compact old memories.
5. **Trajectories (5 tools):** `archivist_log_trajectory` after task execution. `archivist_tips` to retrieve past learnings. `archivist_annotate`, `archivist_rate` for feedback. `archivist_session_end` to persist session summaries.
6. **Skills (6 tools):** `archivist_register_skill`, `archivist_skill_event`, `archivist_skill_lesson`, `archivist_skill_health`, `archivist_skill_relate`, `archivist_skill_dependencies` for MCP tool health tracking.
7. **Admin (7 tools):** `archivist_namespaces`, `archivist_audit_trail`, `archivist_resolve_uri`, `archivist_retrieval_logs`, `archivist_health_dashboard`, `archivist_batch_heuristic`, `archivist_context_check`.
8. **Cache (2 tools):** `archivist_cache_stats`, `archivist_cache_invalidate`.
9. **RBAC:** Pass the **calling** agent as `agent_id` / `caller_agent_id` as documented per tool. For fleet-scoped search, use `agent_ids` / filters as appropriate. If unsure, call `archivist_namespaces` with the caller's `agent_id`.
10. **Fleet conventions (NemoClaw workspaces):** align stored memories with the specialist agent id and namespace used in that agent's `AGENTS.md` (see skill `nemoclaw-agent-fleet`).

## Scripts & References

- `{baseDir}/references/REFERENCE.md` -- tool parameter summary (all 30 tools) and table of fleet namespaces.
- Upstream detail: `archivist-oss/README.md` and `archivist-oss/docs/` in the repo.
- Full parameter reference: `archivist-oss/docs/CURSOR_SKILL.md` (all 30 tools with parameters and examples).

## Security

- Do not exfiltrate other agents' namespaces beyond what RBAC allows. Treat `archivist_*` tool results as sensitive operational context unless the user says otherwise.
