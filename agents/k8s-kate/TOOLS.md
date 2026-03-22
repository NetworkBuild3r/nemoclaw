# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

## NemoClaw AgentSkills (read these)

OpenClaw **does not** list `SKILL.md` files next to AGENTS.md in the session bootstrap. Your workspace includes a **`skills/`** directory (symlink to the repo’s `openclaw-skills/`) so you can open them like any other file:

| Path (under this workspace) | Purpose |
|-----------------------------|--------|
| `skills/kubekate-kubernetes-mcp/SKILL.md` | Your Kubernetes MCP + Archivist workflow |
| `skills/archivist-mcp/` | Fleet memory tool usage |
| `skills/nemoclaw-mcp-fleet/` | MCP server names → roles |
| `skills/nemoclaw-agent-fleet/` | Who owns GitOps vs K8s vs Grafana |

If `skills/` is missing on disk, ensure the repo has `openclaw-skills/` and the `skills` symlink in this folder. The gateway still loads skills via `skills.load.extraDirs` in `openclaw.json`; this tree is so **you** can read the same files in your workspace.

## K8s Cluster — SSH Access

User: `kate` on all nodes. SSH config aliases set up in `~/.ssh/config`.

| Alias | IP | Role |
|-------|----|------|
| `thinkpad` | 192.168.11.129 | Controller (control plane) |
| `k2` | 192.168.11.162 | Worker |
| `k3` | 192.168.11.163 | Worker |

Usage: `ssh thinkpad`, `ssh k2`, `ssh k3`

## MCP Servers

| Server | Endpoint | Purpose |
|--------|----------|---------|
| `kubernetes` | `http://192.168.11.160:8080/kubernetes/mcp` | kubectl via mcp-aggregator |
| `archivist` | `http://192.168.11.142:3100/mcp/sse` | Fleet memory |

## How to Call MCP Tools

OpenClaw does not have a native MCP client. Use the `mcp-call` helper script via `exec`:

```bash
# List available tools on a server
mcp-call kubernetes --list

# Call a tool (pass arguments as JSON)
mcp-call kubernetes kubectl_get '{"resourceType":"nodes"}'
mcp-call kubernetes kubectl_get '{"resourceType":"pods","namespace":"default"}'
mcp-call kubernetes kubectl_describe '{"resourceType":"node","name":"thinkpad"}'
mcp-call kubernetes kubectl_logs '{"name":"my-pod","namespace":"default"}'
mcp-call kubernetes kubectl_scale '{"name":"my-deploy","namespace":"default","replicas":3}'
```

### Archivist MCP

```bash
# Save a finding to memory
mcp-call archivist archivist_store '{"agent_id":"kubekate","namespace":"deployer","text":"Cluster has 3 healthy nodes","tags":["cluster","health"]}'

# Search memory
mcp-call archivist archivist_search '{"query":"node disk usage","agent_id":"kubekate"}'

# Recall entity facts
mcp-call archivist archivist_recall '{"entity":"thinkpad","agent_id":"kubekate"}'

# List your namespaces
mcp-call archivist archivist_namespaces '{"agent_id":"kubekate"}'

# List all archivist tools
mcp-call archivist --list
```

**DO NOT** use `archivist_session_end` — it requires a session_id you don't have. Use `archivist_store` to save findings.

The script is at `/home/bnelson/nemoclaw/scripts/mcp-call.sh` and also on PATH as `mcp-call`.

**Important:** Do NOT use `curl` with GET requests to the MCP endpoint — MCP uses JSON-RPC over HTTP POST. The `mcp-call` helper handles the protocol correctly.
