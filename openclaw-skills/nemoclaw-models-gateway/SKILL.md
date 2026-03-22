---
name: nemoclaw-models-gateway
description: LiteLLM proxy, Bedrock credentials, and OpenClaw model provider wiring for NemoClaw. Use when debugging LLM connectivity, Bedrock auth, or which model id maps to which provider.
metadata: {"openclaw":{}}
---

# Goal

Orient on **how models reach the agents** in this demo: LiteLLM as proxy, optional **Amazon Bedrock** (direct or via LiteLLM), and env files loaded outside git.

## When to Use

- `openclaw` or gateway logs show model/auth errors.
- Explaining `stack/litellm-config.yaml` vs `stack/litellm-config.yaml.example`.
- Setting up AWS keys for Bedrock after Vault changes.

## Instructions

1. **LiteLLM:** Config lives under `stack/` (`stack/README.md`). Production `litellm-config.yaml` is **gitignored**; start from `stack/litellm-config.yaml.example` and local env.
2. **Bedrock env:** Gateway-oriented AWS credentials are synced from Vault to **`.config/openclaw/aws-bedrock.env`** by `scripts/vault-sync-aws-bedrock-env.sh` (see `docs/vault-project-env.md`). File is mode `600` and not committed.
3. **OpenClaw models:** Provider entries (e.g. LiteLLM base URL, Bedrock discovery) live in the host’s `openclaw.json` under `models.providers` — local-only; use `README.md` and `.openclaw/README.md` for conventions.
4. **Restart:** After changing Vault AWS fields or LiteLLM config, restart LiteLLM and the OpenClaw gateway as appropriate.

## Scripts & References

- `{baseDir}/references/REFERENCE.md` — env vars names (no values).

## Security

- Never commit AWS access keys, LiteLLM master keys, or provider API keys. If they ever appeared in a tracked file, **rotate** them in AWS/Vault and strip from history.
