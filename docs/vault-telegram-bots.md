# Telegram bot tokens in HashiCorp Vault

OpenClaw reads Telegram tokens from **files** (`channels.telegram.accounts.*.tokenFile`), not from JSON. This repo **does not** store bot tokens.

## Vault structure (KV v2)

- **Mount:** `kv` (see `vault secrets list`)
- **Path per bot:** `nemoclaw/telegram/<accountId>`
- **Field:** `token` (single string, the BotFather token)

| accountId  | Agent     | Example Vault path              |
|------------|-----------|----------------------------------|
| `chief`    | chief     | `kv/nemoclaw/telegram/chief`     |
| `gitbob`   | gitbob    | `kv/nemoclaw/telegram/gitbob`    |
| `kubekate` | kubekate  | `kv/nemoclaw/telegram/kubekate`  |
| `grafgreg` | grafgreg  | `kv/nemoclaw/telegram/grafgreg`  |

### Write / rotate (UI or CLI)

```bash
export VAULT_ADDR=http://192.168.11.160:8200
vault login   # or use ~/.vault-token

# Example: rotate Chief after BotFather /revoke
vault kv put kv/nemoclaw/telegram/chief token="NEW_TOKEN_HERE"
```

Avoid putting tokens on the shell history; prefer the Vault UI or `token=-` with stdin:

```bash
vault kv put kv/nemoclaw/telegram/chief token=-
# paste token, Ctrl-D
```

## Sync to disk (required before gateway starts)

```bash
cd /home/bnelson/nemoclaw
./scripts/vault-sync-telegram-tokens.sh
```

Writes (canonical paths under the repo; `~/.openclaw` may symlink here):

- `/home/bnelson/nemoclaw/.openclaw/secrets/telegram/chief.token`
- `.../gitbob.token`, `.../kubekate.token`, `.../grafgreg.token` (mode `600`)

The standalone **`argo`** bot is retired — Argo CD is **Kate** (`kubekate`). If you still have `kv/nemoclaw/telegram/argo`, you can delete it after migrating any group topic bindings to **`kubekate`** in `openclaw.json`.

The **systemd** `openclaw-gateway.service` runs this script in `ExecStartPre` so tokens refresh on each gateway start (pick up rotations after Vault is updated).

## Auth (CLI vs systemd)

Interactive CLI can use `vault login`, `~/.vault-token`, or `VAULT_TOKEN` in the environment.

### systemd (`openclaw-gateway.service`)

User services do **not** inherit your shell `VAULT_TOKEN`. The unit loads:

- **`EnvironmentFile=/home/bnelson/nemoclaw/.config/openclaw/vault.env`** (mode `600`) with at least:
  - `VAULT_ADDR=...`
  - `VAULT_TOKEN=...` (renew when the token expires; or switch to **AppRole** / **Vault Agent** later)

After you **rotate** tokens in Vault, run `systemctl --user restart openclaw-gateway.service` — `ExecStartPre` re-runs `vault-sync-telegram-tokens.sh` and refreshes the `*.token` files.

## Agents vs gateway

**OpenClaw / NemoClaw agents** do not read Telegram bot tokens directly. Only the **gateway** needs them to run the Telegram Bot API pollers. Tokens are **not** passed into agent workspaces; routing uses `bindings` + `tokenFile` on the gateway host.

**Forum group vs DMs:** In a Chief-only forum setup, only the **Chief** bot token participates in the supergroup; other accounts (`gitbob`, `kubekate`, …) still use **their** Vault tokens for **private DMs** when those accounts remain enabled and bound. See `docs/CHIEF-FORUM-GROUP.md`.

## Troubleshooting

- Gateway fails at start: run `./scripts/vault-sync-telegram-tokens.sh` manually and fix Vault path / policy until it succeeds.
- `permission denied` on KV: add a policy allowing `read` on `kv/data/nemoclaw/telegram/*` (and `metadata` if your policy requires it).
