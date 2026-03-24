# NemoClaw Architecture — Quick Reference

## System Diagram

```
Host
├── nemoclaw CLI (TypeScript plugin)
│   └── exec.ts spawns python3 runner.py as subprocess
│       ├── stdout protocol: PROGRESS:<0-100>:<label>, RUN_ID:<id>
│       └── runner.py calls openshell CLI → gateway, providers, sandbox, policy
│
├── Archivist + Qdrant (Docker Compose)
│   └── MCP endpoint: http://localhost:3100/mcp/sse
│
├── MCP Aggregator (mcporter)
│   └── Proxies: kubernetes, argocd, grafana, gitlab
│
└── LiteLLM proxy (optional, for Bedrock/multi-provider)

    ↕ openshell sandbox create ↕

OpenShell Sandbox (Landlock + seccomp + netns)
├── OpenClaw + NemoClaw plugin
├── Agent fleet config
├── Inference → OpenShell gateway → NVIDIA cloud
├── MCP → Archivist on host (policy-allowed)
└── MCP → Aggregator on host (policy-allowed)
```

## Blueprint Lifecycle (cross-language)

```
TypeScript (plugin)                    Python (blueprint runner.py)
───────────────────                    ────────────────────────────
1. Resolve  (resolve.ts, fetch.ts)
2. Verify   (verify.ts)
                  │
                  ▼ spawn("python3", [runner.py, action])
                                       3. Plan   (action_plan)
                                       4. Apply  (action_apply)
                                       5. Status (action_status)
                                       6. Rollback (action_rollback)
                  ▲
                  │ parse PROGRESS:/RUN_ID: lines, exit code
```

## Apply Phase — Exact Commands

`action_apply()` in `runner.py` runs these four `openshell` CLI calls in sequence:

```bash
# Step 1: Create sandbox
openshell sandbox create --from <image> --name <name> --forward <port>

# Step 2: Configure inference provider
openshell provider create --name <provider_name> --type <provider_type> \
  --credential <CRED_ENV>=<value> \
  --config OPENAI_BASE_URL=<endpoint>

# Step 3: Set inference route
openshell inference set --provider <provider_name> --model <model>

# Step 4: Save state (Python, not openshell)
# Writes to ~/.nemoclaw/state/runs/<run_id>/plan.json
```

If sandbox already exists ("already exists" in stderr), it is reused. Provider and inference set calls use `check=False` so they don't abort on re-runs.

## Rollback — Exact Commands

```bash
openshell sandbox stop <name>
openshell sandbox remove <name>
# Then marks ~/.nemoclaw/state/runs/<run_id>/rolled_back with timestamp
```

## blueprint.yaml — Profile Structure

The manifest at `nemoclaw-blueprint/blueprint.yaml` declares inference profiles:

| Profile | Provider type | Endpoint | Model | Credential env |
|---------|--------------|----------|-------|---------------|
| `default` | `nvidia` | `https://integrate.api.nvidia.com/v1` | `nvidia/nemotron-3-super-120b-a12b` | (from onboard) |
| `ncp` | `nvidia` | (dynamic) | `nvidia/nemotron-3-super-120b-a12b` | `NVIDIA_API_KEY` |
| `nim-local` | `openai` | `http://nim-service.local:8000/v1` | `nvidia/nemotron-3-super-120b-a12b` | `NIM_API_KEY` |
| `vllm` | `openai` | `http://localhost:8000/v1` | `nvidia/nemotron-3-nano-30b-a3b` | `OPENAI_API_KEY` |

Other manifest fields: `version`, `min_openshell_version`, `min_openclaw_version`, `digest` (SHA-256, computed at release time).

## Key File Locations

| What | Where |
|------|-------|
| Plugin source | `vendor/NemoClaw/nemoclaw/src/` |
| Plugin entry | `vendor/NemoClaw/nemoclaw/src/index.ts` |
| Blueprint bridge | `vendor/NemoClaw/nemoclaw/src/blueprint/exec.ts` |
| Blueprint runner | `vendor/NemoClaw/nemoclaw-blueprint/orchestrator/runner.py` |
| Blueprint manifest | `vendor/NemoClaw/nemoclaw-blueprint/blueprint.yaml` |
| Blueprint cache | `~/.nemoclaw/blueprints/<version>/` |
| Run state | `~/.nemoclaw/state/runs/<run_id>/plan.json` |
| Baseline policy | `nemoclaw-blueprint/policies/openclaw-sandbox.yaml` |
| Policy presets | `nemoclaw-blueprint/policies/presets/` |
| Credentials | `~/.nemoclaw/credentials.json` |
| Sandbox state | `~/.nemoclaw/` |
| OpenClaw state | `~/.openclaw/` |

## Inference Models

```bash
openshell inference set --provider nvidia-nim --model nvidia/nemotron-3-super-120b-a12b
openclaw nemoclaw status          # verify active model
openclaw nemoclaw status --json   # machine-readable
```

## Sandbox Filesystem

Read-write: `/sandbox`, `/tmp`, `/dev/null`
Read-only: `/usr`, `/lib`, `/proc`, `/dev/urandom`, `/app`, `/etc`, `/var/log`

## Upstream Docs

- Architecture: https://docs.nvidia.com/nemoclaw/latest/reference/architecture.html
- How It Works: https://docs.nvidia.com/nemoclaw/latest/about/how-it-works.html
- Inference Profiles: https://docs.nvidia.com/nemoclaw/latest/reference/inference-profiles.html
