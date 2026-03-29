# Findings & Decisions — AHEAD Palo Alto sprint

## Requirements

- NemoClaw sandboxes + Archivist + optional Palo Alto partner story
- No direct agent-to-agent messaging — Archivist only
- Minimal PAN-OS MCP (3+ tools), mock-friendly

## Research Findings

- PAN-OS REST: `/api/?type=op|config&...` — see Palo Alto XML API / REST docs
- MCP transport matches Archivist SSE paths (`/mcp/sse`) for aggregator compatibility

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| Separate namespaces: `tasks`, `mcp-engineering`, `skills-research`, `firewall-ops` | Clear write boundaries per persona |
| `paloalto` MCP behind same aggregator host as other MCPs | Single mcporter pattern |
| **`mcp-builder` owns build + push + deploy** | Demo story: NemoClaw agents ship the MCP, not a pre-loaded image only |

## Issues Encountered

| Issue | Resolution |
|-------|------------|
| | |

## Resources

- `docs/AHEAD-DEMO-RUNBOOK.md`
- `openclaw-skills/ahead-pan-fleet/SKILL.md`
- `mcp-servers/paloalto/`

## Visual/Browser Findings

-

---

## NemoClaw vs OpenClaw (spawn demo)

**Layers**

- **NemoClaw:** OpenShell sandbox, network/filesystem policy, inference routing (e.g. Nemotron). Does **not** replace OpenClaw’s agent list, `sessions_spawn`, or announce semantics.
- **OpenClaw:** Gateway, registered agents, **`sessions_spawn`** (non-blocking), optional announce back to parent, **`openclaw agent`** for host/CLI turns.

**Demo coordination pattern (sufficient without peer A2A)**

- **Chief** → **`sessions_spawn`** → worker agents (`skill-builder`, etc.) with `sandbox: "inherit"` in NemoClaw.
- **Durable bus:** Archivist (`mcp-call` / `skill-engineering`, `tasks`, `chief`) — use when announce is lost (gateway restart).
- **Peer agent-to-agent** (`sessions_send` / advanced routing): **not** required for this challenge if Archivist + spawn cover the story.

**Smooth UX**

- Turn 1 after spawn: **delegated**, not done — tool may return `{ "status": "accepted" }` only.
- Turn 2: summarize only after announce **or** Archivist proof with repo paths.

**Policy**

- Sandbox preset must allow egress to **Archivist** (host/port from `config/mcporter.json` / `ahead_pan_sandbox.preset.yaml`) and any HTTPS doc hosts named in skill-build tasks.

**Verified (2026-03-23):** [`config/policies/ahead_pan_sandbox.preset.yaml`](config/policies/ahead_pan_sandbox.preset.yaml) defines **`archivist`** → `192.168.11.142:3100` (matches [`config/mcporter.json`](config/mcporter.json) `archivist` URL). **`mcp_aggregator`**, **`nvidia_gateway`**, **`brave_search`**, **`container_registry`**, **`gitlab_api`** (placeholder host), **`paloalto_mgmt`** (placeholder) are also declared. **Gap:** there is no blanket “any HTTPS vendor docs” rule — Cisco IOS research from raw `curl` to arbitrary sites would need an added endpoint (or use **Brave Search** / bundled docs in the task). **Verified (2026-03-23):** Preset merged into NemoClaw sandbox (policy versions 6–9 applied). All 8 presets active: `telegram`, `archivist`, `mcp_aggregator`, `k8s_ssh`, `brave_search`, `container_registry`, `gitlab_api`, `paloalto_mgmt`.

### Aggregator wiring (2026-03-23)

- ArgoCD manages the `mcp-aggregator` ConfigMap with `selfHeal: true` from `git@github.com:NetworkBuild3r/home_k3.git`. Direct `kubectl apply` gets reverted within seconds.
- Correct approach: commit route changes to `servers-configmap.yaml` in that repo, push, let ArgoCD sync.
- Cluster naming convention: MCP servers use `mcp-<name>` namespaces. Paloalto deployed to `mcp-paloalto`.
- Private registry at `192.168.11.170:5000`. Placeholders replaced: PAN MGMT → `pan-mock.local`, GitLab → `gitlab.ibhacked.us`.

---

## Chief-only forum Telegram (2026-03-26)

- **Config:** `topics` for supergroup `-1003828106848` all use `agentId: chief`; `gitbob` / `kubekate` / `grafgreg` no longer have `groups` for that id (DM `bindings` unchanged).
- **Sessions:** OpenClaw isolates per `message_thread_id`; new topics need explicit ids in JSON (see `docs/CHIEF-FORUM-GROUP.md`).
- **NemoClaw bridge:** align `TELEGRAM_BOT_TOKEN` with Chief token if both host gateway and sandbox bridge are used (`docs/NEMOCLAW-NVIDIA-STACK.md`).

---

## GitLab MCP authorization + Bob exec issues (2026-03-26)

### GitLab MCP — RESOLVED

- **Symptom:** `mcp-call gitlab list_projects '{}'` initially returned `Error: Unauthorized`
- **Resolution:** MCP server already had valid auth configured internally (user was correct). Issue resolved after aggregator restart.
- **Verified:** Successfully tested `list_projects`, `get_project`, `list_merge_requests` with real data from `gitlab.ibhacked.us`

### Bob exec issue — RESOLVED

- **Symptom:** GitBob (Telegram agent) couldn't execute `/home/bnelson/nemoclaw/scripts/mcp-call.sh`
- **Root cause:** Script not on gateway's `PATH`
- **Fix:** Created `~/.local/bin/mcp-call` symlink; updated `agents/github-bob/AGENTS.md`; gateway restarted
- **Verified:** Bob can now execute `mcp-call` commands

### Large response handling — RESOLVED

- **Symptom:** GitLab returned 393KB of projects → "Argument list too long" error
- **Root cause:** `mcp-call.sh` passed response via Python argv (OS limit ~2MB)
- **Fix:** Updated script to use stdin (`echo "$response" | python3 -c ...`)
- **Verified:** Can now handle responses of any size

**Docs:** `docs/GITBOB-STATUS.md`, `docs/GITLAB-MCP-AUTH-ISSUE.md`, `docs/GITBOB-MCP-EXEC-ISSUE.md`

