---
name: skill-builder
description: Research and author OpenClaw AgentSkills under openclaw-skills/ — layout, symlinks, extraDirs — for NemoClaw skill-builder agents and chiefs who delegate skill work. Ship target is always repo files (not Archivist).
metadata: {"openclaw":{}}
---

# Goal

**Ship repo-native skills** (`openclaw-skills/<name>/SKILL.md`) so **all** OpenClaw agents see the same content via **`skills.load.extraDirs`**. **Research** uses **`brave`**; **deliverables** are **files on disk** + git + optional gateway restart — **not** Archivist stores of the skill body.

## When to Use

- **`ahead-chief`** (or human) assigns a **skill** task: “add skill X for Y integration.”
- **`skill-builder`** must **write** under **`openclaw-skills/<name>/`** and add the **`.cursor/skills/<name>`** symlink.
- Cursor sessions: use when creating or fixing skills the fleet cannot see.

## How work is assigned

- **`tasks`** — optional briefs; read assignment text only.
- **`sessions_spawn`** — Chief spawns **`skill-builder`**; subagent gets **`AGENTS.md` + `TOOLS.md` only** — task string must require **on-disk paths**.
- **Direct routing** — preferred when **writable repo** access is required.

**Chief / parents:** **`sessions_spawn` returns immediately** — verify **`openclaw-skills/<name>/SKILL.md`** exists before claiming done.

## Instructions

1. **Read** [`nemoclaw-skill-builder`](../../.cursor/skills/nemoclaw-skill-builder/SKILL.md) for layout: `openclaw-skills/<skill-name>/`, `.cursor/skills` symlink, `openclaw.json` `extraDirs`.
2. **Research** — `mcp-call brave brave_web_search '{"query":"...","count":8}'` for web/vendor docs; gateway needs **`brave`** in `mcporter.json` and [`mcp-servers/brave-search`](../../mcp-servers/brave-search) + **`BRAVE_API_KEY`**. See **`skills/brave-search/SKILL.md`**.
3. **Author** — create `SKILL.md` + optional `references/REFERENCE.md`; follow **`author-skills-secure`** shape.
4. **Fleet visibility** — the **only** tree other agents use is **`openclaw-skills/<skill-name>/`**. Symlink **`.cursor/skills/<skill-name>`** from repo root. **Commit** `openclaw-skills/`.
5. **Prove** — confirm **`SKILL.md`** exists at **`openclaw-skills/<skill-name>/SKILL.md`**. Do **not** use **`archivist_store`** to replace missing files.

## Scripts & References

- [`nemoclaw-skill-builder`](../../.cursor/skills/nemoclaw-skill-builder/SKILL.md) — full checklist
- [`docs/OPENCLAW-SKILLS.md`](../../docs/OPENCLAW-SKILLS.md) — discovery
- [`agents/skill-builder/AGENTS.md`](../../agents/skill-builder/AGENTS.md) — runtime persona

## Security

No secrets in `SKILL.md`. Use placeholders and Vault paths for env.
