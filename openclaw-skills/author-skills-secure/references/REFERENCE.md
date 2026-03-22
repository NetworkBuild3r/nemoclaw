# Authoring checklist (author-skills-secure)

Use this before merging or publishing a skill.

## Frontmatter

- [ ] `name` matches the directory name (lowercase, hyphens).
- [ ] `description` states **what** the skill does and **when** to invoke it.
- [ ] `metadata.openclaw` lists only privileges the skill actually needs (bins, env, network, files).
- [ ] Complex `metadata` is single-line JSON.

## Body

- [ ] `{baseDir}` used for paths into this skill’s own files (not host-specific secrets).
- [ ] Long examples live under `references/` or `scripts/`, not bloating `SKILL.md`.
- [ ] No real API keys, tokens, or private URLs in examples (use placeholders).

## Security

- [ ] Destructive or prod-impacting flows require explicit human confirmation in instructions.
- [ ] Network targets and protocols documented if the skill implies outbound calls.
- [ ] No broad filesystem access claimed unless the skill truly requires it.

## Integration

- [ ] If the skill needs `openclaw.json` `skills.entries`, the example uses env substitution or placeholders, not live secrets.
