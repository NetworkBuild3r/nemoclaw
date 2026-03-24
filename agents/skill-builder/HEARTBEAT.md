# HEARTBEAT.md

If heartbeats are enabled:

1. **`archivist_search`** for open **`[SKILL-BUILD]`** items in **`tasks`**.
2. **Weekly skill janitor (roughly Mondays):** Review **`nemoclaw-skill-builder`** and **`openclaw-skills/skill-builder`** — tighten instructions, fix stale paths, align with `openclaw.json` **`skills.load.extraDirs`**. **`archivist_store`** into **`skill-engineering`** with tag **`weekly-skill-janitor`** and a short summary.

If nothing needs attention: **`HEARTBEAT_OK`**.

## Exact weekly timing

This repo does **not** define OpenClaw **cron** in `openclaw.json` (version-dependent). For **clock-driven** weekly runs (e.g. Monday 09:00), use a **host systemd timer** or similar that sends a **one-shot message** to **`chief`** or **`skill-builder`** with:

`Weekly skill janitor: run nemoclaw-skill-builder self-review; store results in skill-engineering; archivist_session_end when done.`

Heartbeats are sufficient if **approximate** weekly checks are OK.
