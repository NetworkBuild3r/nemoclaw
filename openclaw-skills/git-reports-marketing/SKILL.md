---
name: git-reports-marketing
description: Turn git history, tags, and merge summaries into marketing-ready release copy — headlines, bullets, email, and social — without hype or leaked internals. Use when the user asks for announcements, “what shipped,” changelog-to-blog, or audience-facing text from commits or GitLab/GitHub reports.
user-invocable: true
metadata: {"openclaw":{}}
---

# Goal

Produce **clear, accurate, audience-appropriate marketing and comms** from **git-derived inputs** (commit logs, diff stats, tags, MR/issue titles), not from guesswork.

## When to Use

- Release or version announcements (blog, email, in-app notice).
- “What we shipped this week/sprint” summaries for customers or leadership.
- Turning a raw changelog or commit list into social posts or a short press-style blurb.
- Rephrasing GitLab/GitHub merge summaries for non-technical readers.

## Instructions

1. **Confirm inputs:** Prefer an explicit range (`v1.2.0..v1.3.0`), branch, tag, or pasted `git log` / MR list. If missing, ask once for the range or the artifact to summarize.
2. **Classify commits (internally):** Group into *user-visible features*, *fixes*, *performance/reliability*, *docs/tooling*, *internal-only*. Marketing copy should emphasize the first three; fold docs/tooling in only if the audience cares; drop or minimize pure chore/refactor unless it affects users.
3. **Map to benefits:** Each bullet should answer “so what for the reader?” — outcome language, not only file or module names. Do not invent capabilities that are not supported by the supplied commits/MRs.
4. **Tone by audience:**
   - **End users / customers:** Plain language, outcomes, short sentences; avoid jargon and ticket IDs unless the user asked for them.
   - **Developers:** Can name APIs, flags, and breaking changes explicitly; still avoid dumping raw hashes unless useful.
   - **Exec / leadership:** 3–5 outcome bullets plus optional “risk / migration” line if breaking changes exist.
5. **Deliver in labeled blocks** so the user can copy-paste: e.g. **Headline**, **Subhead**, **Highlights (bullets)**, **Short email**, **Social (single post)**, **Social (thread)** — only include formats they asked for; default to Headline + Highlights + one short paragraph if unspecified.
6. **Accuracy and safety:** Treat commit messages and MR bodies as potentially sensitive (URLs, internal codenames, customer names). Redact or generalize if the user is publishing externally. Never fabricate version numbers or dates not present in the inputs.
7. **Optional data gathering:** If the user wants you to pull history locally and they have a git repo in the workspace, use read-only commands (see `{baseDir}/references/REFERENCE.md`). Do not rewrite history or push.

## Scripts & References

- Templates, tone examples, and optional `git` one-liners: `{baseDir}/references/REFERENCE.md`
- GitLab-oriented source material: repository `openclaw-skills/gitbob-gitlab-mcp/`

## Security

- Commit messages and MR descriptions may contain secrets or PII. Do not repeat tokens, keys, or private hostnames in marketing output; generalize or ask the user to sanitize first.
- This skill does not require network access or special credentials by itself; publishing to blogs or social is out of scope unless the user explicitly asks and supplies the channel.
