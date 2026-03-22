# Workspace Lifecycle — Quick Reference

## Audit checklist (per agent)

```bash
cd agents/<role>/
ls AGENTS.md SOUL.md IDENTITY.md TOOLS.md USER.md HEARTBEAT.md MEMORY.md 2>/dev/null
ls -d memory/ skills 2>/dev/null
# BOOTSTRAP.md should NOT exist after first session
test -f BOOTSTRAP.md && echo "WARN: BOOTSTRAP.md still present"
```

## Fix missing files

```bash
# Create memory dir and seed MEMORY.md
mkdir -p memory
touch MEMORY.md

# Create skills symlink (from agents/<role>/)
ln -sfn ../../openclaw-skills skills

# Delete stale BOOTSTRAP.md
rm BOOTSTRAP.md
```

## IDENTITY.md fields

Name, Creature, Vibe, Emoji, Avatar (optional).

## Daily notes

One file per day: `memory/YYYY-MM-DD.md`. Append within the day.
