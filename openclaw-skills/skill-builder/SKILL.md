---
name: skill-builder
description: Research and author OpenClaw AgentSkills under openclaw-skills/ — layout, symlinks, extraDirs, Archivist handoff — for NemoClaw skill-builder agents and chiefs who delegate skill work.
metadata: {"openclaw":{}}
---

# Goal

**Ship repo-native skills** (`openclaw-skills/<name>/SKILL.md`) so Cursor and OpenClaw agents discover the same content. **Research** (docs, APIs, conventions) feeds **Archivist**; **deliverables** are files in git plus a summary in namespace **`skill-engineering`**.

## When to Use

- **`ahead-chief`** (or human) assigns a **skill** task: “add skill X for Y integration.”
- **`skill-builder`** agent picks up work from **`tasks`** and writes **`skill-engineering`** when the skill is merged-ready.
- Cursor sessions: use this skill when creating or fixing skills the fleet cannot see.

## How work is assigned (Archivist + OpenClaw spawn)

- **`tasks`** — **`ahead-chief`** / Chief **`archivist_store`** briefs with `[SKILL-BUILD]`; **`skill-builder`** searches **`tasks`**.
- **`sessions_spawn`** — Chief (or any allowed parent) spawns with **`agentId: "skill-builder"`** for isolated one-shots. Subagents get **`AGENTS.md` + `TOOLS.md` only** — put requirements in the **`task`** string and **`archivist_*`** before exit (announce is best-effort).
- **Direct routing** — Normal OpenClaw agent session to **`skill-builder`**.

Archivist holds **durable** deliverables; gateway announce is **not** the system of record.

**Chief / parents:** **`sessions_spawn` returns immediately** — a quick “done” to the human is **not** proof the child authored files. Verify **`skill-engineering`** (or paths in announce) before claiming the skill exists.

## Instructions

1. **Read** [`nemoclaw-skill-builder`](../../.cursor/skills/nemoclaw-skill-builder/SKILL.md) (Cursor skill) for canonical layout: `openclaw-skills/<skill-name>/`, `.cursor/skills` symlink, `openclaw.json` `extraDirs`.
2. **Research** — store raw notes in **`skills-research`** only if you are not the owner (use **`researcher`**) or stash brief clips in **`archivist_search`**; **`skill-builder`** default writes go to **`skill-engineering`** for status and “done” summaries.
3. **Author** — create `SKILL.md` + optional `references/REFERENCE.md`; follow **`author-skills-secure`** shape (Goal → When → Instructions → Scripts & References → Security).
4. **Fleet visibility** — the **only** tree other agents (OpenClaw + `agents/*/skills`) use is **`openclaw-skills/<skill-name>/`**. Add **`.cursor/skills/<skill-name>`** → symlink to that tree; **commit** `openclaw-skills`**. Archivist + **`skill-engineering`** alone are **not** skill discovery. Restart gateway after adding a **new** skill directory if needed.
5. **Prove discovery** — ensure workspace has `skills` → `../../openclaw-skills`; list the new path in the agent’s **`TOOLS.md`**.
6. **Hand off** — `archivist_store` into **`skill-engineering`**: skill name, file paths, PR/MR link, what was tested. For spawned runs, also **`archivist_session_end`** (and optionally **`archivist_log_trajectory`**) so work survives a lost announce.

## Archivist (skill-builder)

- **agent_id:** `skill-builder`
- **Write namespace:** `skill-engineering` (status + deliverable summary)
- **Read:** `tasks` (assignments), `skills-research` (input), any other namespace read-only as needed

## Scripts & References

- [`nemoclaw-skill-builder`](../../.cursor/skills/nemoclaw-skill-builder/SKILL.md) — full checklist
- [`docs/OPENCLAW-SKILLS.md`](../../docs/OPENCLAW-SKILLS.md) — discovery
- [`agents/skill-builder/AGENTS.md`](../../agents/skill-builder/AGENTS.md) — runtime persona

## Security

No secrets in `SKILL.md`. Use placeholders and Vault paths for env.
