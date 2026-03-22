# Git reports → marketing (reference)

## Optional read-only git commands

Run only in a trusted repo and only when the user wants machine-gathered history (adjust refs):

```bash
git log --oneline --no-merges v1.2.0..v1.3.0
git shortlog -sn v1.2.0..v1.3.0
git log --pretty=format:'%h %s' v1.2.0..v1.3.0
```

For a first-pass “what changed” with paths:

```bash
git diff --stat v1.2.0..v1.3.0
```

Prefer MR/title lists from GitLab/GitHub when the team uses squash merges and commit subjects are noisy.

## Output templates (adapt length to channel)

### Headline + subhead

- **Headline:** `[Product] [verb] [primary outcome]` (e.g. “Faster sync and clearer errors in the dashboard”)
- **Subhead:** One sentence tying 2–3 themes; no internal codenames unless the user insisted.

### Highlights (bullets)

- Start with the **user-visible** change, then optional technical detail in parentheses if the audience is technical.
- Order: most impactful first; group related fixes into one bullet if they tell one story.

### Short email (example shape)

1. Greeting + one-line context (release name or date if known).
2. 3–5 bullets (features/fixes).
3. Optional “Migrating?” line for breaking changes.
4. CTA: docs link, upgrade command, or “reply with questions” — only if the user provided a real link or CTA.

### Social

- **Single post:** One hook sentence + 2 bullets + hashtag/CTA only if the user requested.
- **Thread:** Post 1 = hook; follow-ups = one theme per post; final = CTA.

## Checklist before shipping copy

- [ ] Every claim traceable to an input line (commit/MR/tag notes).
- [ ] No invented version numbers, dates, or metrics.
- [ ] Internal-only work de-emphasized or removed for external audiences.
- [ ] Secrets, tokens, internal URLs, and customer-specific names redacted or generalized.
