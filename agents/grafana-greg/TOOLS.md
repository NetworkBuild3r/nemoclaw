# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

## NemoClaw AgentSkills (read these)

OpenClaw **does not** list `SKILL.md` files next to AGENTS.md in the session bootstrap. Your workspace includes a **`skills/`** directory (symlink to the repo's `openclaw-skills/`) so you can open them like any other file:

| Path (under this workspace) | Purpose |
|-----------------------------|--------|
| `skills/grafgreg-grafana-mcp/SKILL.md` | Your Grafana MCP + Archivist workflow |
| `skills/archivist-mcp/` | Fleet memory tool usage |
| `skills/nemoclaw-mcp-fleet/` | MCP server names → roles |
| `skills/nemoclaw-agent-fleet/` | Who owns GitOps vs K8s vs Grafana |

If `skills/` is missing on disk, ensure the repo has `openclaw-skills/` and the `skills` symlink in this folder. The gateway still loads skills via `skills.load.extraDirs` in `openclaw.json`; this tree is so **you** can read the same files in your workspace.

## MCP Servers

| Server | Endpoint | Purpose |
|--------|----------|---------|
| `grafana` | `http://192.168.11.160:8080/grafana/mcp` | Grafana dashboards, PromQL, alerts via mcp-aggregator |
| `archivist` | `http://192.168.11.142:3100/mcp/sse` | Fleet memory |

## How to Call MCP Tools

OpenClaw does not have a native MCP client. Use the `mcp-call` helper script via `exec`:

```bash
# List available tools on a server
mcp-call grafana --list

# Call a tool (pass arguments as JSON)
mcp-call grafana search_dashboards '{"query":""}'
mcp-call grafana get_dashboard_by_uid '{"uid":"abc123"}'
mcp-call grafana list_datasources '{}'
mcp-call grafana query_prometheus '{"query":"up","start":"now-1h","end":"now","step":"60"}'
mcp-call grafana list_alert_rules '{}'
```

### Archivist MCP

```bash
# Save a finding to memory
mcp-call archivist archivist_store '{"agent_id":"grafgreg","namespace":"pipeline","text":"CPU spike on k2 at 14:00","tags":["cpu","anomaly"]}'

# Search memory
mcp-call archivist archivist_search '{"query":"CPU spikes after deploys","agent_id":"grafgreg"}'

# Recall entity facts
mcp-call archivist archivist_recall '{"entity":"k2","agent_id":"grafgreg"}'

# List all archivist tools
mcp-call archivist --list
```

**DO NOT** use `archivist_session_end` — it requires a session_id you don't have. Use `archivist_store` to save findings.

The script is at `/home/bnelson/nemoclaw/scripts/mcp-call.sh` and also on PATH as `mcp-call`.

**Important:** Do NOT use `curl` with GET requests to the MCP endpoint — MCP uses JSON-RPC over HTTP POST. The `mcp-call` helper handles the protocol correctly.
