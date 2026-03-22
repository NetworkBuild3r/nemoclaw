---
name: nemoclaw-deployment
description: NemoClaw deployment — remote GPU via Brev, Telegram bridge, monitoring, troubleshooting. Use when deploying, operating, or debugging a running NemoClaw sandbox.
metadata: {"openclaw":{}}
---

# Goal

Deploy, monitor, and troubleshoot NemoClaw sandboxes — locally, on remote GPU instances, and with Telegram integration.

## When to Use

- Deploying NemoClaw to a remote GPU instance or DGX Spark.
- Setting up the Telegram bridge for always-on chat.
- Monitoring sandbox health, logs, and network activity.
- Diagnosing common failures (install, onboard, runtime, inference).

## Instructions

### 1. Local Deployment

```bash
nemoclaw onboard                    # wizard creates gateway + sandbox
nemoclaw my-assistant connect       # shell in
openclaw tui                        # interactive chat
```

Prerequisites: Linux Ubuntu 22.04+, Node.js 20+, Docker running, OpenShell installed. Minimum 4 vCPU, 8 GB RAM, 20 GB disk. Sandbox image is ~2.4 GB compressed.

### 2. Remote GPU Deployment (Brev)

```bash
nemoclaw deploy <instance-name>
```

The deploy script: installs Docker + NVIDIA Container Toolkit (if GPU), installs OpenShell, runs onboard, starts auxiliary services (Telegram bridge + cloudflared).

GPU selection: `export NEMOCLAW_GPU="a2-highgpu-1g:nvidia-tesla-a100:1"` before deploy.

Monitor remotely: `ssh <instance> 'openshell term'`

### 3. DGX Spark Setup

```bash
sudo nemoclaw setup-spark    # fixes cgroup v2 + Docker config
nemoclaw onboard             # then proceed normally
```

### 4. Telegram Bridge

```bash
export TELEGRAM_BOT_TOKEN=<token-from-BotFather>
export ALLOWED_CHAT_IDS="123456,789012"  # optional
nemoclaw start
nemoclaw status              # verify bridge is running
nemoclaw stop                # when done
```

The bridge forwards messages between Telegram and the OpenClaw agent inside the sandbox. Only runs when `TELEGRAM_BOT_TOKEN` is set.

### 5. Monitoring

| Tool | Command | Purpose |
|------|---------|---------|
| Status | `openclaw nemoclaw status [--json]` | Sandbox state, blueprint run, inference config |
| Logs | `openclaw nemoclaw logs [-f] [-n N] [--run-id ID]` | Blueprint + sandbox log stream |
| TUI | `openshell term` | Live network activity, egress approvals |
| Test | `openclaw agent --agent main --local -m "test" --session-id debug` | Verify inference |

Inside the sandbox, status reports "active (inside sandbox)" — use `openshell sandbox list` on the host for full state.

### 6. Troubleshooting

| Problem | Resolution |
|---------|------------|
| `nemoclaw` not found after install | `source ~/.bashrc` or open new terminal (nvm/fnm PATH issue) |
| Docker not running | `sudo systemctl start docker` |
| npm EACCES permission error | `mkdir -p ~/.npm-global && npm config set prefix ~/.npm-global` then add to PATH |
| Port 18789 in use | `lsof -i :18789` then `kill <PID>` |
| Cgroup v2 errors (Ubuntu 24.04/Spark/WSL2) | `sudo nemoclaw setup-spark` then retry onboard |
| Invalid sandbox name | Use RFC 1123: lowercase alphanumeric + hyphens only |
| Sandbox shows stopped | `nemoclaw onboard` to recreate from same blueprint |
| Inference timeout | Check `openclaw nemoclaw status` for provider/endpoint; verify API key; check network policy |
| Agent can't reach external host | `openshell term` to approve blocked request, or add to policy permanently |
| Blueprint run failed | `openclaw nemoclaw logs --run-id <id>` for error details |
| Status "not running" inside sandbox | Expected — run `openshell sandbox list` on host instead |

## Scripts & References

- `{baseDir}/references/REFERENCE.md` — deployment checklist and env vars.
- Upstream deployment: https://docs.nvidia.com/nemoclaw/latest/deployment/deploy-to-remote-gpu.html
- Upstream Telegram: https://docs.nvidia.com/nemoclaw/latest/deployment/set-up-telegram-bridge.html
- Upstream monitoring: https://docs.nvidia.com/nemoclaw/latest/monitoring/monitor-sandbox-activity.html
- Upstream troubleshooting: https://docs.nvidia.com/nemoclaw/latest/reference/troubleshooting.html

## Security

- `TELEGRAM_BOT_TOKEN` is a secret — set it via env var, never commit to git. Use `ALLOWED_CHAT_IDS` to restrict access.
- Remote deploys via Brev have full VM access — use only with trusted accounts.
- Approved egress endpoints persist only for the session. Make permanent changes via policy YAML.
