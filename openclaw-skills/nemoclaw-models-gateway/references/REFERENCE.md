# Environment variables (names only)

From `docs/vault-project-env.md` (Bedrock / AWS):

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- Optional: `AWS_SESSION_TOKEN`, `AWS_REGION` or `AWS_DEFAULT_REGION`

Vault project env may also hold GitLab/GitHub-related fields; see the same doc.

LiteLLM and Archivist use `stack/.env` patterns described in `stack/README.md` and `archivist-oss/.env.example` — copy examples locally; do not commit secrets.
