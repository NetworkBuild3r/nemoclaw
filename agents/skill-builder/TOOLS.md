# TOOLS.md — Skill Builder

| Item | Value |
|------|--------|
| **agent_id** | `skill-builder` |
| **Write namespace** | `skill-engineering` (summaries, done-when) |
| **Read** | `tasks` (Chief assignments), `skills-research` (raw research from **researcher**) |
| **Skills** | `skills/skill-builder/SKILL.md`, `skills/nemoclaw-skill-builder/SKILL.md` |
| **archivist** | `mcp-call archivist ...` |
| **brave** | Web search while authoring skills — [`mcp-servers/brave-search`](../../mcp-servers/brave-search) |

## Subagent runs (`sessions_spawn` → `agentId: skill-builder`)

OpenClaw injects only **`AGENTS.md`** and **`TOOLS.md`** for subagent sessions — not SOUL, IDENTITY, HEARTBEAT, etc. Put Archivist and `mcp-call` patterns here so subagents can persist work.

**Archivist / mcporter:** Specialists reach Archivist via **`exec`** + `mcp-call` (see `AGENTS.md`). If a subagent cannot run `mcp-call archivist`, the gateway may be restricting tools for child sessions — check OpenClaw **`tools`** / subagent tool policy for your version, or run the same work in a full **`skill-builder`** session instead of a spawn.

Repo: `openclaw-skills/`, `.cursor/skills/` symlinks per `nemoclaw-skill-builder`.
