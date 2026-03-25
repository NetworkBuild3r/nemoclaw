---
name: nemoclaw-mcp-fleet
description: Map MCP server names (kubernetes, argocd, grafana, gitlab, archivist, paloalto, servicenow) to roles and config/mcporter.json. Use when wiring mcporter, debugging MCP URLs, or choosing which specialist tool server to use.
metadata: {"openclaw":{}}
---

# Goal

Connect **mcporter** (and similar MCP clients) to the **HTTP MCP** endpoints declared for this project, and match each server to the **specialist agent** that should use it.

## When to Use

- Editing or explaining `config/mcporter.json`.
- Telling GitBob vs Argo vs KubeKate vs GrafGreg which MCP namespace to call.
- Debugging "which URL is Archivist vs Kubernetes?".

## Instructions

1. **Authoritative config:** Read `config/mcporter.json` in the repo. It lists `mcpServers` with `url` and `description`. Hostnames and ports are **environment-specific**; treat them as deployment values, not portable constants.
2. **Server roles:**
   - **kubernetes** — cluster operations (KubeKate).
   - **argocd** — Argo CD apps, sync, history (Argo).
   - **grafana** — dashboards, PromQL, alerts (GrafGreg).
   - **gitlab** — projects, MRs, pipelines (GitBob; GitLab API via MCP).
   - **archivist** — fleet long-term memory (all agents, with RBAC).
   - **paloalto** — Palo Alto PAN-OS management MCP (`mcp-servers/paloalto`; `palo-expert`). Backend SSE path is **`/mcp/sse`** — aggregator must proxy to it (see `deploy/k8s/mcp-aggregator/README.md`).
   - **servicenow** — Incidents + change requests (`mcp-servers/servicenow`; Chief / change workflows). Same **`/mcp/sse`** pattern; deploy with `deploy/k8s/servicenow-mcp/`.
   - **brave** — Brave Search (`mcp-servers/brave-search`, `brave_web_search`, `BRAVE_API_KEY`, `http://127.0.0.1:8770/mcp`).
3. **Transport:** MCP endpoints use **JSON-RPC over HTTP POST** (streamable HTTP). Do NOT use GET requests — they return 404.
4. **Calling MCP tools from OpenClaw:** Use the `mcp-call` helper script via `exec`:
   - `mcp-call <server> <tool> '<json-args>'` — call a tool
   - `mcp-call <server> --list` — list available tools
   - Example: `mcp-call kubernetes kubectl_get '{"resourceType":"nodes"}'`
   - The script is at `/home/bnelson/nemoclaw/scripts/mcp-call.sh` and on PATH as `mcp-call`.
5. **Changing endpoints:** Update `config/mcporter.json` (or your client's equivalent) when the MCP aggregator or Archivist host moves. The `mcp-call` script reads `MCP_AGGREGATOR` env var (default: `http://192.168.11.160:8080`).

## Scripts & References

- `{baseDir}/references/REFERENCE.md` — server → agent mapping table.

## Security

- MCP URLs often sit on internal networks. Do not expose aggregator URLs publicly without authentication and network controls. Never embed API keys for MCP into skills; gateway auth is separate from MCP HTTP URLs in this layout.
