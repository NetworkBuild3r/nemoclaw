---
name: nemoclaw-skill-builder
description: Add or update NemoClaw AgentSkills in this repo — canonical openclaw-skills layout, Cursor symlinks, openclaw.json extraDirs, and authoring checklist. Use when creating nemoclaw skills, fixing skills agents cannot see, or aligning with AGENTS.md and OpenClaw discovery.
user-invocable: true
metadata: {"openclaw":{"always":true}}
---

# Goal

Ship **NemoClaw skills** so both **Cursor** and **OpenClaw runtime agents** (Telegram/gateway) use the same `SKILL.md` content — without duplicating trees or relying on `.cursor/skills/` alone.

## When to Use

- Adding, renaming, or removing a skill under this repository.
- The user says OpenClaw agents “don’t see” a skill that only exists under `.cursor/skills/`.
- Reviewing frontmatter, `{baseDir}` paths, or `metadata.openclaw` for a new skill.
- Splitting a large skill into `references/REFERENCE.md`.

## Instructions

1. **Canonical directory:** Create the skill only under **`openclaw-skills/<skill-name>/`** at the repo root (`<skill-name>` must match the `name` field in frontmatter; lowercase, hyphens). **Never** treat **`.cursor/skills/`** or an Archivist **`skill-engineering`** note as sufficient — OpenClaw loads from **`extraDirs` → `openclaw-skills/`**; other agents will not see the skill until it exists there and is committed.
2. **Workspace visibility:** OpenClaw’s **bootstrap** only loads AGENTS.md, SOUL.md, TOOLS.md, IDENTITY.md, USER.md, etc. — **not** `SKILL.md`. So each agent workspace should have **`skills` → symlink to `../../openclaw-skills`** (from `agents/<role>/`) so runtime agents can **read** `skills/<name>/SKILL.md` like normal files. Mention key paths in **`TOOLS.md`** or **`AGENTS.md`**.

   **Subagent spawns (`sessions_spawn`):** Injected files are **only `AGENTS.md` + `TOOLS.md`** — not SOUL, IDENTITY, HEARTBEAT, etc. Anything the child must “remember” for Archivist or layout belongs in **`TOOLS.md`**, **`AGENTS.md`**, or the parent’s **`task`** string.
3. **Cursor:** Add a **symlink** so the IDE loads the same tree:
   - From `nemoclaw/.cursor/skills/`: `ln -sfn ../../openclaw-skills/<skill-name> <skill-name>`
   - Do **not** maintain a second copy of `SKILL.md` only under `.cursor/skills/`.
4. **OpenClaw:** Ensure **`skills.load.extraDirs`** in `openclaw.json` includes the absolute path to `.../nemoclaw/openclaw-skills` (see `docs/OPENCLAW-SKILLS.md`). Adding files under `openclaw-skills/` does not require editing `openclaw.json` unless you change the directory path or add a *second* extra root.
5. **Format:** Follow **`author-skills-secure`** (repo skill `author-skills-secure`): Goal → When to Use → Instructions → Scripts & References → Security; single-line frontmatter; single-line JSON for `metadata`; move long material to `{baseDir}/references/REFERENCE.md`.
6. **NemoClaw content:** Tie specialist skills to **`agents/<role>/AGENTS.md`** (MCP server name, Archivist `agent_id` / `namespace`). Cross-link shared skills (`archivist-mcp`, `nemoclaw-mcp-fleet`, `nemoclaw-agent-fleet`) by path under `openclaw-skills/`, not `.cursor/skills/`.
7. **After config changes:** Restart the **OpenClaw gateway** when only `openclaw.json` (or `extraDirs`) changes — new files under an already-listed `extraDirs` path are picked up on the next skill reload/restart depending on version; if in doubt, restart.
8. **Deliverable:** Give the full directory layout (`openclaw-skills/<name>/SKILL.md`, optional `references/REFERENCE.md`) plus the symlink command for `.cursor/skills/`.
9. **Fleet roles:** For **agent-authored** skills, see **`openclaw-skills/skill-builder/SKILL.md`** (Brave **`brave`** + on-disk **`openclaw-skills/<name>/`**) and **`openclaw-skills/mcp-builder/SKILL.md`** (MCP servers + **`mcp-engineering`**). **`ahead-chief`** may assign `[SKILL-BUILD]` in **`tasks`** — skill-builder still **ships to git files**, not Archivist.

## Scripts & References

- `{baseDir}/references/REFERENCE.md` — discovery cheat sheet, pitfalls, and checklist.
- Global OpenClaw vs Cursor: `docs/OPENCLAW-SKILLS.md`
- Authoring standard: `openclaw-skills/author-skills-secure/` (also available as Cursor skill `author-skills-secure`)

## Security

- Never commit tokens, API keys, or live `openclaw.json` **skills.entries** secrets into skills; use placeholders and env-backed config. Rotate any key ever pasted into a tracked file.
- Keep `metadata.openclaw` honest: do not claim `network`, `bins`, or env vars the skill text does not actually require for its documented workflow.
