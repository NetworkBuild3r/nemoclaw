# GitHub submission checklist (AHEAD × NVIDIA NemoClaw Challenge)

**Deadline:** March 31, 2026 · **Contact:** eric.kaplan@ahead.com

## Challenge deliverables (you ship these)

| # | Deliverable | Notes |
|---|-------------|--------|
| 1 | **One slide** | Value prop + architecture — not stored in this repo |
| 2 | **Demo video** | &lt; 5 minutes, show the real system — host on Drive/YouTube, link in email |
| 3 | **Public GitHub repo** | This tree (or a fork) with **no secrets** |

## Repo readiness (maintain this before `git push`)

- [ ] **`git init`** (or clone) and first commit only after secrets are scrubbed.
- [ ] **`stack/litellm-config.yaml`** is **gitignored**; only **`stack/litellm-config.yaml.example`** is tracked. Real config stays local.
- [ ] **`.openclaw/`** and **`.config/openclaw/`** stay gitignored (tokens, `openclaw.json` may contain API keys in `skills` — never force-add).
- [ ] **`stack/.env`** — no secrets in tracked files; use Vault docs in `docs/vault-*.md`.
- [ ] **Rotate** any key that was ever pasted into a tracked file, chat, or screenshot.
- [ ] Root **`README.md`**: what you built, enterprise use case, how to run (high level), link to upstream **github.com/NVIDIA/NemoClaw**.
- [ ] **`LICENSE`** at repo root (e.g. Apache-2.0 or MIT — match your employer policy).

## What reviewers should see

- **NemoClaw / OpenClaw** as the backbone (agents, policies, gateway).
- **Enterprise story** (e.g. DevOps / GitOps fleet + shared memory) — your `agents/`, `docs/`, Archivist integration.
- **Ecosystem**: NVIDIA (Nemotron, embeddings, Bedrock via LiteLLM) + optional partner — describe in README, redact IPs if needed.

## What’s in the repo

- **`archivist-oss/`** — **fully included** (Python service + tests + docs). The nested upstream `.git` was moved to **`.upstream-archivist-git-backup/`** (gitignored) so your **local patches** ship with the monorepo. Judges should open **[`archivist-oss/README.md`](../archivist-oss/README.md)** for the full story.
- **`vendor/NemoClaw/`** — **excluded** (~1GB). Document `git clone https://github.com/NVIDIA/NemoClaw` next to this repo (see root `README.md`).
