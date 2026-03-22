# NemoClaw repo — quick pointers

## Run Archivist + Qdrant (from repo root)

```bash
cd archivist-oss
docker compose -f docker-compose.yml -f ../stack/docker-compose.override.yml --env-file ../stack/.env up -d
```

## Docs index

| Topic | Path |
|--------|------|
| Archivist in this demo | `docs/ARCHIVIST.md` |
| Vault project env | `docs/vault-project-env.md` |
| Telegram bots + Vault | `docs/vault-telegram-bots.md` |
| GitHub submission | `docs/GITHUB-SUBMISSION.md` |

## Scripts (repo root)

| Script | Role |
|--------|------|
| `scripts/nemoclaw-env-from-vault.sh` | Load project env into shell (`eval "$(./scripts/nemoclaw-env-from-vault.sh)"`) |
| `scripts/vault-sync-telegram-tokens.sh` | Vault → `*.token` files for Telegram |
| `scripts/vault-sync-aws-bedrock-env.sh` | Vault → `aws-bedrock.env` for gateway |
