# NemoClaw runtime stack (LiteLLM + Archivist overrides)

- **`litellm-config.yaml`** — LiteLLM proxy (Bedrock + NVIDIA); used by `litellm-bedrock.service`.
- **`.env`** — Archivist / embedding env for Docker Compose (not committed; see `.env.example` if added).
- **`docker-compose.override.yml`** — Overrides for `archivist-oss/docker-compose.yml` (paths are relative to this directory: `../sample-memories`, `../config`).

## Archivist + Qdrant

From the repo root:

```bash
cd /home/bnelson/nemoclaw/archivist-oss
docker compose -f docker-compose.yml -f ../stack/docker-compose.override.yml --env-file ../stack/.env up -d
```

Ensure `../stack/.env` exists (copy from the previous `nemoclaw-challenge/.env` or your secret store).
