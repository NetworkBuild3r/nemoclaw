# TOOLS.md - Skill Builder

| Item | Value |
|------|--------|
| **agent_id** | `skill-builder` |
| **Workspace** | `agents/skill-builder` - includes **`openclaw-skills/`** subdirectory for direct writes (no sandbox mount issues) |
| **Ship target (only)** | **`openclaw-skills/<name>/`** on disk + **`.cursor/skills/<name>`** symlink from repo root - this is what other agents load via `skills.load.extraDirs`. **Do not** treat Archivist as the place skills "live." |
| **Write path** | `./openclaw-skills/<name>/SKILL.md` (relative to this workspace) - writable without sudo/mount tricks |
| **Read** | **`tasks`** (assignment briefs from Chief/ahead-chief only, if used) |
| **Skills** | `skills/skill-builder/SKILL.md`, `skills/nemoclaw-skill-builder/SKILL.md`, **`skills/brave-search/SKILL.md`** (web research) |
| **brave** | **Brave Search MCP** - use for **all** external web/doc research before you author or cite APIs (see below) |

## Your Workspace Layout

```
agents/skill-builder/
├── openclaw-skills/          # ← WRITE HERE (local to this workspace)
│   └── <name>/
│       ├── SKILL.md
│       └── references/
│           └── REFERENCE.md
├── skills/                   # ← symlink to ../../openclaw-skills (for reading existing skills)
├── AGENTS.md, SOUL.md, etc.
└── mcporter.json             # → symlink to ../../config/mcporter.json
```

**After you write `./openclaw-skills/<name>/SKILL.md`:**
1. Create the repo-root symlink: `cd ../.. && ln -sfn ../../openclaw-skills/<name> .cursor/skills/<name>`
2. Verify: `test -f ./openclaw-skills/<name>/SKILL.md && echo "✓ Skill exists"`
3. Log to Archivist `skill-engineering` namespace with paths

**Why this works:** Your workspace has a **direct `openclaw-skills/` subdirectory** (not just the symlink). When you write `./openclaw-skills/<name>/SKILL.md`, it goes to disk immediately - no sandbox mount issues. Other agents still load from the **repo-level** `openclaw-skills/` via `skills.load.extraDirs`, which your workspace contributes to.

## Brave Search (research - use this)

You **must** use **`brave`** for internet research (vendor docs, API behavior, version notes). Do not guess URLs or API shapes from memory alone when a quick search would disambiguate.

**Host prerequisites (Brian / gateway):**

1. **`brave`** entry in **`mcporter.json`** (this workspace has **`mcporter.json`** → repo `config/mcporter.json`). Default URL: `http://127.0.0.1:8770/mcp`.
2. **Brave MCP process** running: [`mcp-servers/brave-search`](../../mcp-servers/brave-search) with **`BRAVE_API_KEY`** set ([Brave Search API](https://brave.com/search/api/)).
3. **NemoClaw sandbox:** policy should include **`brave_search`** egress to `api.search.brave.com` (see `config/policies/ahead_pan_sandbox.preset.yaml`).

**Calls (JSON third argument - required):**

```bash
mcp-call brave --list
mcp-call brave brave_web_search '{"query":"PAN-OS XML API xpath security rules","count":8}'
```

Wrong: `mcp-call brave brave_web_search` with no JSON (will error). Full skill: **`skills/brave-search/SKILL.md`**.

## Subagent runs (`sessions_spawn` → `agentId: skill-builder`)

OpenClaw injects only **`AGENTS.md`** and **`TOOLS.md`** for subagent sessions — not SOUL, IDENTITY, HEARTBEAT, etc. Subagents **persist the skill only by writing files** under **`./openclaw-skills/<name>/`** (from your workspace) and creating the **repo-root** symlink. **`mcporter.json`** in this workspace shows MCP URLs; **`brave`** is required for research.

**Pattern for subagent skill creation:**

```bash
# 1. Research (if Brave is available)
mcp-call brave brave_web_search '{"query":"<technology> API documentation","count":5}'

# 2. Create directories
mkdir -p ./openclaw-skills/<name>/references

# 3. Write SKILL.md
write ./openclaw-skills/<name>/SKILL.md <<'EOF'
# Skill Title
**name:** <name>
...
EOF

# 4. Write optional references
write ./openclaw-skills/<name>/references/REFERENCE.md <<'EOF'
# References
...
EOF

# 5. Create symlink from repo root
cd ../.. && ln -sfn ../../openclaw-skills/<name> .cursor/skills/<name>

# 6. Verify
test -f agents/skill-builder/openclaw-skills/<name>/SKILL.md && echo "✓ Skill file exists"
test -L .cursor/skills/<name> && echo "✓ Symlink created"

# 7. Log to Archivist
mcp-call archivist archivist_store '{"agent_id":"skill-builder","namespace":"skill-engineering","text":"Skill <name> delivered: openclaw-skills/<name>/SKILL.md + symlink","tags":["skill-delivered","<name>"]}'
```

If **`write`/`exec`** is blocked in a spawn, finish the job in a **full skill-builder session** (or Cursor) where the repo is writable — **do not** substitute Archivist for the skill files.

## Why new files never appear under `openclaw-skills/` (debug)

1. **"Done" was narrative only** - `sessions_spawn` returns immediately; the model may **describe** a plan without **`write`/`exec`** creating files. **Proof** = **`openclaw-skills/<name>/SKILL.md`** exists on disk (and symlink). No Archivist substitute.

2. **NemoClaw sandbox filesystem** - Sandboxes are often **writable only under `/sandbox` and `/tmp`**. **`openclaw-skills/`** must be **writable** from the skill-builder process (bind-mount or run **without** sandbox for skill authoring). If writes fail: **report failure** and fix the mount/policy - **do not** store the skill in Archivist.

3. **Host OpenClaw** - From `agents/skill-builder`, paths like **`../../openclaw-skills/<name>/`** must succeed for the gateway user. Fix **permissions** or build the skill **in Cursor** on the repo.

4. **Symlink** - From **repo root**: `ln -sfn ../../openclaw-skills/<name> .cursor/skills/<name>` (target is relative to `.cursor/skills/` → `../../openclaw-skills/<name>`).
