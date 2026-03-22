# OpenClaw runtime skills (not Cursor-only)

OpenClaw loads **AgentSkills** from `SKILL.md` trees. It does **not** read `.cursor/skills/` (that path is for Cursor in the IDE).

## Where skills live in this repo

| Location | Used by |
|----------|---------|
| **`openclaw-skills/`** | OpenClaw gateway (via config below) |
| **`.cursor/skills/`** | Cursor — symlinks into `openclaw-skills/` |

## Required `openclaw.json` fragment

Merge into your existing `skills` object (paths must match your clone location):

```json
"skills": {
  "load": {
    "extraDirs": [
      "$HOME/nemoclaw/openclaw-skills"
    ]
  }
}
```

Keep your existing `skills.install` and `skills.entries` if present.

## Apply changes

Restart the OpenClaw gateway after editing `openclaw.json` so skills reload.

## How OpenClaw discovers skills (OpenClaw package)

Per workspace, skills are merged from bundled dirs, `~/.openclaw/skills`, `{workspace}/skills`, `{workspace}/.agents/skills`, **`skills.load.extraDirs`**, and more. See `node_modules/openclaw/dist/skills-*.js` (`loadSkillEntries`) in your install.

## Adding skills in this repo

Use the **`nemoclaw-skill-builder`** AgentSkill under `openclaw-skills/nemoclaw-skill-builder/` (it explains the `openclaw-skills/` + `.cursor/skills` symlink workflow).

## Why agents don’t “see” SKILL.md next to AGENTS.md

Session **bootstrap** loads fixed filenames (AGENTS.md, SOUL.md, TOOLS.md, …) — not AgentSkills. Skills are still injected via the skills prompt when `extraDirs` / workspace `skills/` discovery runs. To **open skill files as paths** in a workspace, this repo adds **`agents/<role>/skills` → symlink to `openclaw-skills/`** so `skills/kubekate-kubernetes-mcp/SKILL.md` etc. exist under the agent workspace.
