# Vault — non-secret examples

Replace placeholders with your environment. Do not commit real values.

```bash
export VAULT_ADDR=http://YOUR_VAULT_HOST:8200
# Authenticate: vault login, or source a local vault.env with VAULT_TOKEN

vault kv get kv/nemoclaw/project-env
vault kv patch kv/nemoclaw/project-env EXAMPLE_KEY="example-value"
```

Telegram token write (prefer stdin to avoid shell history):

```bash
vault kv put kv/nemoclaw/telegram/chief token=-
# paste token, Ctrl-D
```

Sync from repo root:

```bash
cd /path/to/nemoclaw
./scripts/vault-sync-telegram-tokens.sh
./scripts/vault-sync-aws-bedrock-env.sh
```
