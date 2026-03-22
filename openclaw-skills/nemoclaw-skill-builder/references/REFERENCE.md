# NemoClaw skill builder — reference

## Lessons learned (this repo)

| Mistake | Fix |
|---------|-----|
| Skills only under **`.cursor/skills/`** | OpenClaw **does not** read that path. Canonical tree is **`openclaw-skills/`** + **`skills.load.extraDirs`** in `openclaw.json`. |
| Duplicated `SKILL.md` in two places | One tree in **`openclaw-skills/<name>/`**; **`.cursor/skills/<name>`** → symlink only. |
| Expecting per-agent `.cursor/skills` to run bots | Runtime uses **workspace** + **extraDirs** + managed/bundled dirs (see OpenClaw `loadSkillEntries` in `node_modules/openclaw/dist/skills-*.js`). |
| Agent only “sees” AGENTS.md / SOUL.md / TOOLS.md | **Bootstrap** does not include `SKILL.md`. Add **`skills` → `../../openclaw-skills`** under each `agents/<role>/` so `skills/<name>/SKILL.md` exists as readable paths; document in TOOLS.md / AGENTS.md. **`workspace-default`:** use `ln -sfn ../openclaw-skills skills` (one `..`, not two). |
| Forgetting reload | After **`openclaw.json`** edits, **restart the gateway**. New files under an existing `extraDirs` path may still need a restart depending on version. |
| Wrong cross-links in prose | Link sibling skills as **`openclaw-skills/...`** (not `.cursor/skills/...`) so text is true for OpenClaw and Cursor. |

## OpenClaw discovery (simplified)

Merged skill lists come from multiple roots, including:

- Bundled package `skills/`
- `~/.openclaw/skills` (managed)
- `{workspace}/skills` and `{workspace}/.agents/skills`
- **`skills.load.extraDirs`** — this repo points one entry at **`openclaw-skills/`**

Later sources in the implementation can override same **skill name**; keep **unique `name:`** values across roots you control.

## Add a new skill — commands

From repo root (`nemoclaw`):

```bash
# 1. Create tree (example: my-new-skill)
mkdir -p openclaw-skills/my-new-skill/references
# edit openclaw-skills/my-new-skill/SKILL.md and optional references/REFERENCE.md

# 2. Cursor symlink
mkdir -p .cursor/skills
ln -sfn ../../openclaw-skills/my-new-skill .cursor/skills/my-new-skill
```

## Checklist before merge

- [ ] `name` matches folder name; lowercase-hyphenated.
- [ ] `description` covers **what** + **when**.
- [ ] No secrets; placeholders only in examples.
- [ ] `metadata.openclaw` matches real needs.
- [ ] `openclaw-skills/` updated; `.cursor/skills/` is symlink, not a duplicate file.
- [ ] Specialist skills align with `agents/<role>/AGENTS.md` if applicable.
