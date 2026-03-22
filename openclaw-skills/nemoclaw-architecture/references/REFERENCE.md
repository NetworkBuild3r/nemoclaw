# NemoClaw Architecture — Quick Reference

## System Diagram

```
Host
├── nemoclaw CLI (TypeScript plugin)
│   └── blueprint runner (Python subprocess)
│       └── openshell CLI → gateway, providers, sandbox, policy
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

## Blueprint Lifecycle

Resolve → Verify digest → Plan resources → Apply via openshell → Status

## Key File Locations

| What | Where |
|------|-------|
| Plugin source | `vendor/NemoClaw/nemoclaw/src/` |
| Blueprint | `vendor/NemoClaw/nemoclaw-blueprint/` |
| Blueprint cache | `~/.nemoclaw/blueprints/<version>/` |
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
