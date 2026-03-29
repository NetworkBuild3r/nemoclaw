---
name: nemoclaw-workspace-lifecycle
description: Agent workspace file conventions — BOOTSTRAP deletion, MEMORY.md creation, IDENTITY format, TOOLS customization, daily note naming. Use when onboarding agents, auditing workspace completeness, or fixing missing lifecycle files.
metadata: {"openclaw":{}}
---

# Goal

Keep every agent workspace under `agents/<role>/` structurally consistent and lifecycle-correct so bootstrap, memory, and identity flows work without runtime errors.

## When to Use

- Onboarding a new agent or auditing an existing workspace.
- An agent reports "file not found" for MEMORY.md, memory/, or daily notes.
- Reviewing workspace consistency before a submission or demo.

## Instructions

### Required Files per Workspace

| File | Purpose | Create if missing? |
|------|---------|--------------------|
| `AGENTS.md` | Role, rules, Archivist usage, **fleet engineering rules** (`agents/ENGINEERING_ALGORITHM.md`) | Yes (from `docs/reference/templates/AGENTS.md`; fleet agents must include the Tesla/SpaceX–style five-step mandate) |
| `SOUL.md` | Persona and voice | Yes (from template) |
| `IDENTITY.md` | Name, Creature, Vibe, Emoji, Avatar | Yes — see format below |
| `TOOLS.md` | Agent-specific tool notes (MCP endpoints, SSH, paths) | Yes — customize per agent |
| `USER.md` | Human context | Yes (from template) |
| `HEARTBEAT.md` | Proactive check config | Yes (from template) |
| `MEMORY.md` | Long-term curated memory | Yes — create empty or seeded |
| `memory/` | Daily note directory | Yes — `mkdir -p memory/` |
| `skills` | Symlink → `../../openclaw-skills` | Yes — for runtime skill access |

### BOOTSTRAP.md Lifecycle

- Present only before the agent's first run.
- After first session: the agent reads it, configures itself, then **deletes** it.
- If `BOOTSTRAP.md` still exists in a workspace that has had sessions, it should be removed.

### IDENTITY.md Format (Canonical)

```markdown
# IDENTITY.md — Who Am I?

- **Name:** <display name> (<agent-id>)
- **Creature:** <one-line metaphor for how this agent operates>
- **Vibe:** <personality archetype> — <short qualifier>
- **Emoji:** <single emoji>
- **Avatar:** *(optional — workspace-relative path, URL, or data URI)*

<One sentence capturing the agent's core stance.>
```

All agents should use this five-field format for consistency.

### TOOLS.md Customization

The generic template is a starting point. Each agent should document:
- MCP server name and key tool names they use
- SSH hosts or connection details (if applicable)
- AgentSkill paths: `skills/<skill-name>/SKILL.md`
- Archivist `agent_id` and `namespace`

### Daily Note Naming

Convention: `memory/YYYY-MM-DD.md` (one per calendar day, append if multiple sessions). Avoid timestamps or descriptive suffixes in filenames — put that context inside the file.

## Scripts & References

- `{baseDir}/references/REFERENCE.md` — per-workspace checklist.
- Templates: `docs/reference/templates/` (AGENTS.md, SOUL.md, TOOLS.md, USER.md, HEARTBEAT.md, IDENTITY.md, BOOTSTRAP.md).

## Security

- `MEMORY.md` is for main sessions only — do not load in shared/group contexts.
- Never store secrets (tokens, keys, passwords) in workspace files. Use Vault paths per `nemoclaw-vault-scripts`.
