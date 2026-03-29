# TOOLS.md - Local Notes

**Workspace:** `agents/chief` — OpenClaw **`agentId` `chief`**, Telegram account **`chief`** (token file unchanged).

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
| **Kate (`kubekate`)** | Kubernetes **and** Argo CD | `kubernetes`, `argocd` |
| **GitBob** | GitLab CI/CD | `gitlab` |
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

If **`exec`** reports **`mcp-call: not found`**, the gateway **`PATH`** may be too minimal — use the **absolute script** (always works):

```bash
/home/bnelson/nemoclaw/scripts/mcp-call.sh archivist archivist_search '{"query":"coordination","agent_id":"chief","namespace":"chief","refine":false,"min_score":0}'
```

### Skill status (skill-builder)

**Proof of delivery** = **`openclaw-skills/<name>/SKILL.md`** (and symlink) in the **repo** — not Archivist. Ask Brian or check git/MR.

```bash
# Optional: assignment briefs still in tasks
mcp-call archivist archivist_search '{"query":"[SKILL-BUILD] synology","agent_id":"chief","namespace":"tasks","refine":false,"min_score":0}'
```

If **`mcp-call`** is missing from **`PATH`**, prefix with **`/home/bnelson/nemoclaw/scripts/mcp-call.sh`** on every line above.

**Archivist is slow** (often 10–60s on first call). If you see **`Error: no response received from MCP (SSE)`**, the helper already uses a **120s** read window; set **`ARCHIVIST_SSE_READ_SECONDS=180`** in **`gateway.env`** (see `scripts/gateway.env.example`) or ensure Archivist/Qdrant is healthy.

Available servers: `kubernetes`, `argocd`, `grafana`, `gitlab`, `archivist`

### Archivist MCP (your main direct tool)

**New session / boot — load your own memory first.** Semantic search defaults to **`refine: true`**, which can return **empty `sources`** and the message *“Found chunks but none were relevant after refinement”* even when memories exist — the refiner rejects chunks that don’t match a vague query (e.g. “NemoClaw coordination”). **Do not** treat that as “nothing stored.”

Use this order:

1. **Index (fast, reliable):** list what exists in your namespace  
   `mcp-call archivist archivist_index '{"agent_id":"chief","namespace":"chief"}'`

2. **Search with refinement OFF** — always include **`namespace":"chief"`** for your coordination store, and set **`refine":false`** (and usually **`min_score":0`**) for recall:  
   `mcp-call archivist archivist_search '{"query":"recent coordination","agent_id":"chief","namespace":"chief","refine":false,"min_score":0}'`

3. **Timeline (optional):**  
   `mcp-call archivist archivist_timeline '{"query":"chief","agent_id":"chief","namespace":"chief","days":30}'`

```bash
# Save a coordination decision
mcp-call archivist archivist_store '{"agent_id":"chief","namespace":"chief","text":"Delegated disk alert to KubeKate","tags":["coordination"]}'

# Search YOUR namespace (refine off for “what did we store?” — see above)
mcp-call archivist archivist_search '{"query":"past incident responses","agent_id":"chief","namespace":"chief","refine":false,"min_score":0}'

# Recall entity facts
mcp-call archivist archivist_recall '{"entity":"frontend","agent_id":"chief"}'
```

**DO NOT** use `archivist_session_end` — it requires a session_id you don't have. Use `archivist_store` to save findings.

The script is at **`/home/bnelson/nemoclaw/scripts/mcp-call.sh`** and on **`PATH`** as **`mcp-call`** when the gateway service includes **`~/.local/bin`** (see `openclaw-gateway.service`).

**Important:** Do NOT use `curl` with GET requests to MCP endpoints — MCP uses JSON-RPC over HTTP POST. The `mcp-call` helper handles the protocol correctly.
