---
name: nemoclaw-vault-scripts
description: Vault KV paths, systemd env files, and shell scripts used by NemoClaw (Telegram tokens, Bedrock env, project env). Use when syncing secrets, debugging gateway startup, or documenting bootstrap without putting secrets in git.
metadata: {"openclaw":{}}
---

# Goal

Operate **HashiCorp Vault** and the repo’s **sync scripts** safely: know which paths exist, which files land on disk, and what must never be committed.

## When to Use

- Rotating Telegram bot tokens or AWS credentials for Bedrock.
- Explaining why `nemoclaw/.env` has no secrets.
- Debugging `systemd` `ExecStartPre` or missing `vault.env`.

## Instructions

1. **Project secrets (KV):** Canonical documentation is `docs/vault-project-env.md`. Typical path: `kv/nemoclaw/project-env` for GitLab/GitHub-related fields, plus `VAULT_ADDR` / `VAULT_TOKEN` bootstrap (see doc for exact fields).
2. **Telegram tokens:** One path per bot account, e.g. `kv/nemoclaw/telegram/<accountId>` with field `token`. Full table: `docs/vault-telegram-bots.md`.
3. **Disk targets (canonical under repo):** Sync scripts write mode-`600` files such as:
   - `~/.openclaw/secrets/telegram/<accountId>.token` (gitignored tree)
   - `~/.config/openclaw/aws-bedrock.env` (gitignored)
   - `~/.config/openclaw/vault.env` (gitignored) for `VAULT_ADDR` + `VAULT_TOKEN` used by systemd
4. **Scripts:** From repo root:
   - `./scripts/vault-sync-telegram-tokens.sh` — Vault → Telegram token files
   - `./scripts/vault-sync-aws-bedrock-env.sh` — Vault → Bedrock env file
   - `eval "$(./scripts/nemoclaw-env-from-vault.sh)"` — load project env into shell
5. **After changing Vault:** Restart the user gateway (`systemctl --user restart openclaw-gateway.service` or equivalent) so `ExecStartPre` re-runs sync scripts.

## Scripts & References

- `{baseDir}/references/REFERENCE.md` — minimal command examples (no secrets).

## Security

- Never paste Vault tokens, bot tokens, or AWS keys into skills, issues, or `openclaw.json` committed to git. **Rotate** any key that was ever pasted into a tracked file.
- Scripts require a working `vault` CLI and network access to `VAULT_ADDR`. Do not broaden `metadata.openclaw` beyond what these workflows actually use.
