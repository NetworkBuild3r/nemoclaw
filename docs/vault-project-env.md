# Project environment secrets (no `nemoclaw/.env`)

All **project** secrets that used to live in `nemoclaw/.env` are stored in **Vault KV v2**:

- **Path:** `kv/nemoclaw/project-env`
- **Fields:** `github_token`, `GITLAB_USERNAME`, `GITLAB_PASS`, `GITLAB_TOKEN`, plus **`VAULT_ADDR`** and **`VAULT_TOKEN`** (authoritative copy; see bootstrap below)
- **Amazon Bedrock (OpenClaw gateway):** set at least **`AWS_ACCESS_KEY_ID`** and **`AWS_SECRET_ACCESS_KEY`** (IAM user or STS keys with `bedrock:InvokeModel` / `bedrock:InvokeModelWithResponseStream` in the target region). Optional: **`AWS_SESSION_TOKEN`**, **`AWS_REGION`** or **`AWS_DEFAULT_REGION`** (default `us-east-1` if omitted). On each gateway start, `vault-sync-aws-bedrock-env.sh` writes **`/home/bnelson/nemoclaw/.config/openclaw/aws-bedrock.env`** (mode `600`; `~/.config/openclaw` may symlink here) and systemd loads it for the Node process. If these keys are missing, the script warns and continues so Telegram still works; Bedrock calls fail until you patch Vault and restart the gateway.

### Add or rotate

```bash
export VAULT_ADDR=http://192.168.11.160:8200
source /home/bnelson/nemoclaw/.config/openclaw/vault.env   # VAULT_TOKEN

vault kv patch kv/nemoclaw/project-env GITLAB_TOKEN="new-token"
```

Bedrock AWS keys (after creating an IAM user or access key with Bedrock invoke permissions in your account):

```bash
vault kv patch kv/nemoclaw/project-env \
  AWS_ACCESS_KEY_ID="AKIA..." \
  AWS_SECRET_ACCESS_KEY="..." \
  AWS_REGION="us-east-1"
# optional: AWS_SESSION_TOKEN="..."  # if using temporary credentials
```

Then: `systemctl --user restart openclaw-gateway.service` (or run `./scripts/vault-sync-aws-bedrock-env.sh` and restart).

Inspect (redact in screenshots):

```bash
vault kv get kv/nemoclaw/project-env
```

## Bootstrap (first hop)

The **first** secret the host needs is a Vault token (or other Vault auth) so `vault kv get` works. A copy of **`VAULT_ADDR`** + **`VAULT_TOKEN`** is also stored **in** `kv/nemoclaw/project-env` for backup and team sync — but something must still bootstrap the CLI.

**Practical setup:**

- **File (canonical):** `/home/bnelson/nemoclaw/.config/openclaw/vault.env` (mode `600`). `~/.config/openclaw/vault.env` resolves here via symlink.
  - `VAULT_ADDR=...`
  - `VAULT_TOKEN=...` (keep in sync with Vault when you rotate; or use `vault login` + `~/.vault-token` instead of this file)

This file is what **`openclaw-gateway.service`** uses for `ExecStartPre` (Vault → Telegram `*.token` files). It is **not** committed to git.

Longer term, prefer **AppRole** + **Vault Agent** auto-auth so no long-lived token file on disk.

## Shell sessions (developers / scripts)

Load project env vars into your **current** shell:

```bash
cd /home/bnelson/nemoclaw
eval "$(./scripts/nemoclaw-env-from-vault.sh)"
```

## `nemoclaw/.env`

The file is **empty of secrets** — only comments pointing here. Do not reintroduce plaintext keys.
