---
name: nemoclaw-agent-fleet
description: NemoClaw OpenClaw agent roster (Chief, GitBob, Argo, KubeKate, GrafGreg), delegation rules, workspaces, and Archivist namespaces. Use when routing tasks, editing AGENTS.md, or aligning memory writes with the right agent_id.
metadata: {"openclaw":{}}
---

# Goal

Run the **GitOps agent fleet** correctly: who leads, who executes cluster/Git/Argo/Grafana work, and how **Archivist** namespaces map to each agent.

## When to Use

- “Which agent should handle this?”
- Editing `agents/*/AGENTS.md` or OpenClaw `agents.list` entries.
- Storing memories with consistent `agent_id` / `namespace`.

## Instructions

1. **Chief (`chief`):** Coordinator only. **Does not** run GitLab, Argo CD, kubectl, or Grafana tools directly — delegates to specialists. Stores coordination decisions in Archivist with `agent_id: "chief"`, `namespace: "chief"`.
2. **GitBob (`gitbob`):** GitLab (and Git-adjacent) work via **gitlab** MCP. Namespace **`pipeline`** for Archivist stores.
3. **Argo (`argo`):** Argo CD via **argocd** MCP. Namespace **`deployer`**.
4. **KubeKate (`kubekate`):** Kubernetes via **kubernetes** MCP. Namespace **`deployer`**.
5. **GrafGreg (`grafgreg`):** Grafana via **grafana** MCP. Namespace **`pipeline`** for metrics/alert context.
6. **Workspaces:** Each agent has a directory under `agents/<role>/` with `AGENTS.md`, `IDENTITY.md`, `SOUL.md`, `TOOLS.md`, `MEMORY.md`, and `memory/` dir. For the full file checklist and lifecycle conventions, see `openclaw-skills/nemoclaw-workspace-lifecycle/SKILL.md`.
7. **Safety:** Specialists must confirm destructive actions (delete, rollback, scale to zero) per each `AGENTS.md`.

## Scripts & References

- `{baseDir}/references/REFERENCE.md` — one-line summary table.
- Per-agent behavior: `agents/gitops-chief/AGENTS.md`, `agents/github-bob/AGENTS.md`, etc.

## Security

- Delegation limits blast radius: do not use specialist MCP tools from the wrong agent persona when policies route by Telegram/OpenClaw `agentId`.
