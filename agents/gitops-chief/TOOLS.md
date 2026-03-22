# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

## NemoClaw AgentSkills (read these)

OpenClaw **does not** list `SKILL.md` files next to AGENTS.md in the session bootstrap. Your workspace includes a **`skills/`** directory (symlink to the repo's `openclaw-skills/`) so you can open them like any other file:

| Path (under this workspace) | Purpose |
|-----------------------------|--------|
| `skills/chief-gitops-delegation/SKILL.md` | Your delegation workflow + Archivist chief namespace |
| `skills/archivist-mcp/` | Fleet memory tool usage |
| `skills/nemoclaw-mcp-fleet/` | MCP server names → roles |
| `skills/nemoclaw-agent-fleet/` | Who owns GitOps vs K8s vs Grafana |
| `skills/nemoclaw-openclaw-telegram/` | Telegram routing and troubleshooting |

If `skills/` is missing on disk, ensure the repo has `openclaw-skills/` and the `skills` symlink in this folder. The gateway still loads skills via `skills.load.extraDirs` in `openclaw.json`; this tree is so **you** can read the same files in your workspace.

## Delegation — You Do NOT Run MCP Tools Directly

You coordinate and delegate. Your team runs the specialist tools:

| Agent | Specialty | MCP Server |
|-------|-----------|------------|
| **KubeKate** | Kubernetes ops | `kubernetes` |
| **GitBob** | GitLab CI/CD | `gitlab` |
| **Argo** | ArgoCD GitOps | `argocd` |
| **GrafGreg** | Grafana metrics | `grafana` |

All agents share **archivist** (`http://192.168.11.142:3100/mcp/sse`) for fleet memory.

## MCP Servers

You only use Archivist directly (for cross-team context):

| Server | Endpoint | Purpose |
|--------|----------|---------|
| `archivist` | `http://192.168.11.142:3100/mcp/sse` | Fleet memory |

## How to Call MCP Tools

OpenClaw does not have a native MCP client. Use the `mcp-call` helper script via `exec`:

```bash
# List available tools on any server
mcp-call kubernetes --list
mcp-call argocd --list
mcp-call grafana --list
mcp-call gitlab --list
mcp-call archivist --list
```

Available servers: `kubernetes`, `argocd`, `grafana`, `gitlab`, `archivist`

### Archivist MCP (your main direct tool)

```bash
# Save a coordination decision
mcp-call archivist archivist_store '{"agent_id":"chief","namespace":"chief","text":"Delegated disk alert to KubeKate","tags":["coordination"]}'

# Search fleet memory
mcp-call archivist archivist_search '{"query":"past incident responses","agent_id":"chief"}'

# Recall entity facts
mcp-call archivist archivist_recall '{"entity":"frontend","agent_id":"chief"}'
```

**DO NOT** use `archivist_session_end` — it requires a session_id you don't have. Use `archivist_store` to save findings.

The script is at `/home/bnelson/nemoclaw/scripts/mcp-call.sh` and also on PATH as `mcp-call`.

**Important:** Do NOT use `curl` with GET requests to MCP endpoints — MCP uses JSON-RPC over HTTP POST. The `mcp-call` helper handles the protocol correctly.
