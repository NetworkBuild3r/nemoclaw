---
name: nemoclaw-agent-fleet
description: NemoClaw OpenClaw agent roster (Chief, GitBob, Kate/kubekate K8s+Argo CD, GrafGreg, snow-birdman / Birdman), delegation rules, workspaces, and Archivist namespaces. Use when routing tasks, editing AGENTS.md, or aligning memory writes with the right agent_id.
metadata: {"openclaw":{}}
---

# Goal

Run the **GitOps agent fleet** correctly: who leads, who executes cluster/Git/Argo/Grafana work, and how **Archivist** namespaces map to each agent. For the full breakout (layers, **Chief** vs **ahead-chief**, registration), see **`docs/FLEET-ROSTER.md`** at the repo root.

## When to Use

- “Which agent should handle this?”
- Editing `agents/*/AGENTS.md` or OpenClaw `agents.list` entries.
- Storing memories with consistent `agent_id` / `namespace`.

## Instructions

0. **Fleet engineering rules (every agent):** Tesla / SpaceX–style five-step sequence — (1) make requirements less dumb, (2) delete waste, (3) optimize, (4) accelerate the *right* process, (5) automate **last**. Full text: `agents/ENGINEERING_ALGORITHM.md`. Do not reorder; do not automate or “go faster” before deleting waste and validating requirements.
1. **Chief (`chief`):** Coordinator only. **Does not** run GitLab, kubectl, Argo CD, Grafana, or ServiceNow MCP tools directly — delegates to specialists (**Kate** owns both K8s and Argo CD MCPs; **Birdman** for SNOW). Stores coordination decisions in Archivist with `agent_id: "chief"`, `namespace: "chief"`.
2. **GitBob (`gitbob`):** GitLab (and Git-adjacent) work via **gitlab** MCP. Namespace **`pipeline`** for Archivist stores.
3. **Kate (`kubekate`):** **Kubernetes** (`kubernetes` MCP) **and Argo CD** (`argocd` MCP). Namespace **`deployer`**. There is no separate `argo` agent.
4. **GrafGreg (`grafgreg`):** Grafana via **grafana** MCP. Namespace **`pipeline`** for metrics/alert context.
5. **Birdman (`snow-birdman`):** ServiceNow via **servicenow** MCP — incidents and **change requests** (change control / CAB). Namespace **`change-control`** for Archivist stores.
6. **Factory (two roles only):** **`mcp-builder`** (Forge) — ship MCP images and k8s deploys; **`skill-builder`** (Quill, primary model **`openclaw-opus-46`** / `litellm-local/openclaw-opus-46`) — research, playbooks, and repo **`openclaw-skills/`**. There is no separate **`argo`**, **`researcher`**, or **`skill-author`** agent id.
7. **Workspaces:** Each agent has a directory under `agents/<role>/` with `AGENTS.md`, `IDENTITY.md`, `SOUL.md`, `TOOLS.md`, `MEMORY.md`, and `memory/` dir. For the full file checklist and lifecycle conventions, see `openclaw-skills/nemoclaw-workspace-lifecycle/SKILL.md`.
8. **Safety:** Specialists must confirm destructive actions (delete, rollback, scale to zero) per each `AGENTS.md`.

## OpenClaw A2A vs Archivist (do not duplicate)

- **Live execution and routing** — OpenClaw **gateway**: channels, Telegram topic bindings, `agents.list`, **`sessions_spawn`** / **`/subagents spawn`**, and talking to a named agent session. **NemoClaw** adds sandbox/policy only; it does **not** replace OpenClaw coordination.
- **Durable memory and receipts** — **Archivist** (`archivist_store`, `tasks`, trajectories, **`archivist_session_end`**): what shipped, handoffs, and “what to do next” when sessions restart. It is **not** a second real-time agent-to-agent chat layer.
- **Exception — `skill-builder`:** AgentSkills ship in **`openclaw-skills/`** (git), not as Archivist “skill bodies.”
- **Pattern:** Route work through OpenClaw; **persist** outcomes and briefs in Archivist where appropriate — **except** Quill’s **`SKILL.md`** files (repo-only).

## Scripts & References

- `agents/ENGINEERING_ALGORITHM.md` — Tesla / SpaceX–style fleet rules (order enforced; full table + anti-patterns).
- `{baseDir}/references/REFERENCE.md` — one-line summary table.
- Per-agent behavior: `agents/chief/AGENTS.md`, `agents/github-bob/AGENTS.md`, etc.

## Security

- Delegation limits blast radius: do not use specialist MCP tools from the wrong agent persona when policies route by Telegram/OpenClaw `agentId`.
