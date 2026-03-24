# NemoClaw NVIDIA Stack — Bootstrap & Second-Server Guide

This document describes how to set up the NemoClaw NVIDIA-aligned stack from a fresh clone of this repo. It covers OpenShell, the NemoClaw plugin + blueprint, NVIDIA cloud inference, Archivist memory, and the single-repo-root portable layout.

## Architecture

```
Host (repo root)
├── OpenShell gateway
├── Archivist + Qdrant (docker compose)
└── agents/, openclaw-skills/, config/

    ↕ openshell sandbox create ↕

OpenShell Sandbox
├── OpenClaw + NemoClaw plugin
├── Agent fleet config (migrated from host)
├── Inference → OpenShell → NVIDIA cloud
└── MCP → Archivist on host (policy-allowed)
```

## Prerequisites

| Dependency       | Minimum  | Verified on this host |
|------------------|----------|-----------------------|
| Linux            | Ubuntu 22.04+ | Ubuntu 22.04      |
| Node.js          | 20+      | 22.22.1               |
| npm              | 10+      | 10.9.4                |
| Python 3         | 3.10+    | 3.12.7                |
| Docker           | 24+      | 29.3.0                |
| OpenShell        | 0.1.0+   | 0.0.12                |

## Step 1: Clone & Symlinks

```bash
git clone <your-repo-url> ~/nemoclaw
cd ~/nemoclaw

# Create runtime directories (gitignored)
mkdir -p .openclaw .nemoclaw

# Symlink so OpenClaw and NemoClaw use the repo as their state root
ln -sfn ~/nemoclaw/.openclaw ~/.openclaw
ln -sfn ~/nemoclaw/.nemoclaw ~/.nemoclaw
```

## Step 2: Install NemoClaw CLI

Install the NemoClaw standalone CLI from the vendored copy:

```bash
cd ~/nemoclaw/vendor/NemoClaw
npm install --ignore-scripts
npm install -g ~/nemoclaw/vendor/NemoClaw
nemoclaw --help
```

## Step 3: Install NemoClaw OpenClaw Plugin

```bash
openclaw plugins install ~/nemoclaw/vendor/NemoClaw/nemoclaw
```

This registers the `openclaw nemoclaw` subcommands and the NVIDIA inference provider.

## Step 4: Set Up Blueprint Cache

The blueprint OCI fetch is not yet implemented in alpha. Populate the local cache:

```bash
mkdir -p ~/.nemoclaw/blueprints/0.1.0
cp -r ~/nemoclaw/vendor/NemoClaw/nemoclaw-blueprint/* ~/.nemoclaw/blueprints/0.1.0/
```

Remove the `digest:` line from `~/.nemoclaw/blueprints/0.1.0/blueprint.yaml` (or set it to an empty YAML null) to skip digest verification for local development.

## Step 5: Start Archivist

```bash
cd ~/nemoclaw/archivist-oss

# Copy and edit the env file with your NVIDIA API key
cp ../stack/.env.example ../stack/.env
# Edit stack/.env: set EMBED_API_KEY, LLM_API_KEY (NVIDIA nvapi-... key)

docker compose -f docker-compose.yml -f ../stack/docker-compose.override.yml \
  --env-file ../stack/.env up -d

# Verify
curl -s http://localhost:3100/health
```

## Step 6: OpenClaw Config

If this is a fresh server, copy the example config:

```bash
cp ~/nemoclaw/config/openclaw.json.example ~/.openclaw/openclaw.json
# Edit: replace /home/YOU with your actual home directory
# Edit: generate a random gateway token
```

If migrating from an existing host, your `.openclaw/openclaw.json` should already be populated.

## Step 7: NemoClaw Onboard (Create Sandbox)

```bash
nemoclaw onboard
```

The wizard will:
- Create an OpenShell gateway (if not present)
- Prompt for your NVIDIA API key (`nvapi-...`)
- Create the sandbox from `ghcr.io/nvidia/openshell-community/sandboxes/openclaw:latest`
- Apply baseline network + filesystem policies

## Step 8: Migrate Host Config into Sandbox

```bash
openclaw nemoclaw migrate --dry-run   # preview what will be packed
openclaw nemoclaw migrate             # execute
```

The migrate command snapshots `~/.openclaw`, packs external roots (agent workspaces, skills), copies everything into the sandbox at `/sandbox/.nemoclaw/migration/...`, and rewrites config paths.

If the migrate hangs during blueprint apply (known alpha issue with `openshell sandbox create` blocking on ssh), the sandbox is already created. Kill the process and manually upload:

```bash
# Create snapshot
python3 -c "
import sys; sys.path.insert(0, '$HOME/.nemoclaw/blueprints/0.1.0')
from migrations.snapshot import create_snapshot
print(create_snapshot())
"

# Upload snapshot + workspaces
openshell sandbox upload openclaw ~/.nemoclaw/snapshots/<timestamp>/openclaw /sandbox/.openclaw --no-git-ignore
openshell sandbox upload openclaw ~/nemoclaw/agents/chief /sandbox/.nemoclaw/migration/workspaces/workspaces-chief-workspace --no-git-ignore
# ... repeat for each agent workspace and openclaw-skills
```

## Step 9: Apply Policy Presets

```bash
# Programmatic approach (non-interactive):
node -e "
const p = require('$HOME/nemoclaw/vendor/NemoClaw/bin/lib/policies');
p.applyPreset('openclaw', 'telegram');
p.applyPreset('openclaw', 'archivist');
p.applyPreset('openclaw', 'mcp_aggregator');
"

# Verify
nemoclaw openclaw policy-list
```

Before applying, ensure the Archivist preset YAML at `vendor/NemoClaw/nemoclaw-blueprint/policies/presets/archivist.yaml` has the correct host IP. On this server, the docker0 bridge IP is the one the sandbox can reach:

```bash
ip -4 addr show docker0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
# e.g. 172.17.0.1
```

Update `config/policies/archivist.preset.yaml` with this IP.

## Step 10: Upload MCP Config to Sandbox

Create a `mcporter.json` for the sandbox that uses the host bridge IP for Archivist:

```bash
# Already created at config/mcporter.json.example — fill in IPs
# Upload to sandbox
openshell sandbox upload openclaw /path/to/sandbox-mcporter.json /sandbox/.openclaw/mcporter.json
```

## Step 11: Connect and Validate

```bash
nemoclaw openclaw connect

# Inside the sandbox:
openclaw nemoclaw status
openclaw agent --agent main --local -m "hello" --session-id test
```

## Second-Server Checklist

To reproduce this setup on another machine:

1. Clone the repo (includes `archivist-oss/`, `agents/`, `openclaw-skills/`, `config/`, `vendor/NemoClaw/`)
2. Create symlinks: `~/.openclaw` and `~/.nemoclaw` → repo dirs
3. Install: Node 20+, Docker, OpenShell, `npm install -g vendor/NemoClaw`
4. Copy secrets from Vault / secure transfer:
   - `stack/.env` (NVIDIA API keys for Archivist)
   - `~/.nemoclaw/credentials.json` (NVIDIA API key for inference)
   - `~/.openclaw/secrets/telegram/*.token` (Telegram bot tokens)
5. Start Archivist compose
6. Run `nemoclaw onboard` + `openclaw nemoclaw migrate`
7. Apply policy presets (telegram, archivist, mcp_aggregator)
8. Upload sandbox mcporter.json with new host's bridge IP
9. Connect and verify

## File Layout Reference

| Path | In git? | Purpose |
|------|---------|---------|
| `archivist-oss/` | Yes | Archivist + Qdrant service |
| `agents/` | Yes | Agent workspaces (Chief, GitBob, Argo, Kate, Greg) |
| `openclaw-skills/` | Yes | OpenClaw runtime AgentSkills |
| `config/` | Yes | Templates: `mcporter.json.example`, `openclaw.json.example`, `policies/*.example` |
| `config/policies/` | Partial | `.example` files committed; concrete `.yaml` with real IPs gitignored via `.env` pattern |
| `stack/` | Yes | `docker-compose.override.yml`, `.env.example` |
| `vendor/NemoClaw/` | Optional | Upstream NemoClaw clone (or git submodule) |
| `.openclaw/` | No | Runtime state, `openclaw.json`, sessions, tokens |
| `.nemoclaw/` | No | Blueprint cache, credentials, sandbox registry |
| `stack/.env` | No | Live NVIDIA API keys for Archivist |
