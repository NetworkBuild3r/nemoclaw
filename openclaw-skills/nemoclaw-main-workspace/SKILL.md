---
name: nemoclaw-main-workspace
description: Default OpenClaw workspace — points to repo-wide NemoClaw skills and agent fleet when no GitOps sub-workspace is open. Use for sessions bound to agents.defaults.workspace.
metadata: {"openclaw":{"always":true}}
---

# Goal

When this **default workspace** is active (no `agents/<role>` tree), still align with the **NemoClaw** repo: use repository root `openclaw-skills/` (OpenClaw runtime) for Archivist, MCP layout, Vault, and routing docs.

## When to Use

- Agent **`main`** or any profile using `workspace-default` as its workspace path.
- General tasks that are not scoped to Chief / GitBob / Argo / KubeKate / GrafGreg workspaces.

## Instructions

1. **Engineering algorithm:** Same as the fleet — apply `agents/ENGINEERING_ALGORITHM.md` in order (requirements → delete waste → optimize → accelerate → automate).
2. **Prefer the repo root** as the working tree: `/home/bnelson/nemoclaw` (or your clone path) so shared skills and `config/mcporter.json` resolve predictably. **GitHub:** [github.com/NetworkBuild3r/nemoclaw](https://github.com/NetworkBuild3r/nemoclaw).
3. **Routing:** For GitOps-style asks, read `nemoclaw-agent-fleet` and delegate conceptually to the right specialist persona — or open that agent’s folder as workspace for their dedicated skill.
4. **Cross-cutting:** Use `nemoclaw-overview`, `archivist-mcp`, `nemoclaw-mcp-fleet`, `nemoclaw-openclaw-telegram` as needed.

## Scripts & References

- Repo overview: `{baseDir}/../../../README.md`
- Full skill index: repository root `openclaw-skills/` (IDE may mirror via `.cursor/skills/` symlinks)

## Security

- Same as repo-wide policies: no secrets in skills; tokens stay in Vault-synced paths per docs.
