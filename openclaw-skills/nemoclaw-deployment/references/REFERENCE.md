# NemoClaw Deployment — Quick Reference

## Environment Variables

| Variable | Required | Purpose |
|----------|----------|---------|
| `NVIDIA_API_KEY` | Yes (onboard) | NVIDIA cloud inference. Stored in `~/.nemoclaw/credentials.json` after first onboard. |
| `TELEGRAM_BOT_TOKEN` | For Telegram | Bot token from @BotFather. |
| `ALLOWED_CHAT_IDS` | Optional | Comma-separated Telegram chat IDs to restrict access. |
| `NEMOCLAW_GPU` | Optional | GPU type for remote deploy. Default: `a2-highgpu-1g:nvidia-tesla-a100:1`. |

## Prerequisites Matrix

| Dependency | Version | Check |
|------------|---------|-------|
| Linux | Ubuntu 22.04+ | `lsb_release -a` |
| Node.js | 20+ | `node --version` |
| npm | 10+ | `npm --version` |
| Docker | Running | `docker info` |
| OpenShell | Installed | `openshell --version` |

## Hardware

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU | 4 vCPU | 4+ vCPU |
| RAM | 8 GB | 16 GB |
| Disk | 20 GB free | 40 GB free |

## This Repo's Deployment (Challenge)

```bash
# 1. Start Archivist
cd ~/nemoclaw/archivist-oss
docker compose -f docker-compose.yml -f ../stack/docker-compose.override.yml --env-file ../stack/.env up -d

# 2. Onboard sandbox
nemoclaw onboard

# 3. Migrate host config
openclaw nemoclaw migrate

# 4. Apply policy presets
nemoclaw openclaw policy-add  # or:
openshell policy set config/policies/archivist.preset.yaml
openshell policy set config/policies/mcp_aggregator.preset.yaml

# 5. Upload MCP config
openshell sandbox upload openclaw config/mcporter.json /sandbox/.openclaw/mcporter.json

# 6. Connect and verify
nemoclaw openclaw connect
openclaw agent --agent main --local -m "hello" --session-id test
```
