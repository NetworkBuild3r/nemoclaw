---
name: nemoclaw-architecture
description: NemoClaw architecture — design principles, plugin/blueprint split, sandbox environment, blueprint lifecycle, inference routing, filesystem/network isolation. Use when designing, extending, or debugging the NemoClaw stack.
metadata: {"openclaw":{}}
---

# Goal

Provide a correct mental model of **NemoClaw's architecture** so agents and humans can design extensions, debug issues, and reason about security boundaries without misunderstanding how the pieces fit together.

## When to Use

- Explaining how NemoClaw works to someone new.
- Designing a new policy, inference route, or sandbox customization.
- Debugging why a sandbox, blueprint, or inference call fails.
- Reviewing architecture alignment before submission.

## Instructions

### 1. Design Principles

NemoClaw follows five architectural principles:

1. **Thin plugin, versioned blueprint** — the plugin stays small and stable; orchestration logic lives in the blueprint and evolves on its own release cadence.
2. **Respect CLI boundaries** — `nemoclaw` is the primary interface; plugin commands live under `openclaw nemoclaw` and never override built-in OpenClaw commands.
3. **Supply chain safety** — blueprints are immutable, versioned, digest-verified before execution.
4. **OpenShell-native for new installs** — for users without existing OpenClaw, recommend `openshell sandbox create` directly.
5. **Reproducible setup** — running setup again recreates the sandbox from the same blueprint and policy definitions.

### 2. Two-Part Architecture

**Plugin** (TypeScript) — thin CLI layer, runs in-process with OpenClaw gateway:

```
nemoclaw/
├── src/
│   ├── index.ts              Plugin entry
│   ├── cli.ts                Commander.js subcommand wiring
│   ├── commands/
│   │   ├── launch.ts         Fresh install into OpenShell
│   │   ├── connect.ts        Interactive shell into sandbox
│   │   ├── status.ts         Blueprint run state + sandbox health
│   │   ├── logs.ts           Stream blueprint and sandbox logs
│   │   └── slash.ts          /nemoclaw chat command handler
│   └── blueprint/
│       ├── resolve.ts        Version resolution, cache management
│       ├── fetch.ts          Download blueprint from OCI registry
│       ├── verify.ts         Digest verification
│       ├── exec.ts           Subprocess execution of blueprint runner
│       └── state.ts          Persistent state (run IDs)
├── openclaw.plugin.json      Plugin manifest
└── package.json
```

**Blueprint** (Python) — versioned artifact with its own release stream:

```
nemoclaw-blueprint/
├── blueprint.yaml            Manifest: version, profiles, compatibility
├── orchestrator/
│   └── runner.py             CLI runner: plan / apply / status
├── policies/
│   └── openclaw-sandbox.yaml Strict baseline network + filesystem policy
```

### 3. Blueprint Lifecycle

Five phases, in order: **Resolve → Verify → Plan → Apply → Status**.

The lifecycle spans **two languages**: Resolve and Verify run in the **TypeScript plugin**; Plan, Apply, Status, and Rollback run in the **Python blueprint runner** (`runner.py`). The plugin bridges them by spawning `python3 orchestrator/runner.py <action>` as a child process via `exec.ts`.

**Runner protocol** (stdout line-based):
- `PROGRESS:<0-100>:<label>` — parsed by the plugin as progress updates.
- `RUN_ID:<id>` — reports the run identifier (format: `nc-YYYYMMDD-HHMMSS-<8hex>`).
- Exit code `0` = success, non-zero = failure.

Environment variables set by the plugin: `NEMOCLAW_BLUEPRINT_PATH` (artifact directory), `NEMOCLAW_ACTION` (the action being run).

#### Phase details

1. **Resolve** (TypeScript: `resolve.ts`) — locate the blueprint artifact. Checks local cache at `~/.nemoclaw/blueprints/<version>/` first; falls back to OCI registry download via `fetch.ts`. Returns a `ResolvedBlueprint` with `localPath`, `manifest`, and `cached` flag. Does **not** check version compatibility — that happens in Verify.
2. **Verify** (TypeScript: `verify.ts`) — two checks: (a) `verifyBlueprintDigest()` computes SHA-256 over every file in the blueprint directory and compares against `manifest.digest`; (b) `checkCompatibility()` compares host `openshell --version` and `openclaw --version` against `min_openshell_version` / `min_openclaw_version` from `blueprint.yaml`.
3. **Plan** (Python: `runner.py` `action_plan()`) — validates the selected profile exists in `blueprint.yaml`, checks `openshell` CLI is on PATH, resolves sandbox config (image, name, ports) and inference config (provider, endpoint, model, credential env var). Outputs the plan as JSON to stdout.
4. **Apply** (Python: `runner.py` `action_apply()`) — executes four steps in sequence:
   - `openshell sandbox create --from <image> --name <name> [--forward <port>]`
   - `openshell provider create --name <provider> --type <type> [--credential <env>=<val>] [--config OPENAI_BASE_URL=<endpoint>]`
   - `openshell inference set --provider <provider> --model <model>`
   - Saves run state to `~/.nemoclaw/state/runs/<run_id>/plan.json`
5. **Status** (Python: `runner.py` `action_status()`) — reads the most recent (or specified) run's `plan.json` from `~/.nemoclaw/state/runs/` and prints it.
6. **Rollback** (Python: `runner.py` `action_rollback()`) — stops and removes the sandbox for a given run ID via `openshell sandbox stop` + `openshell sandbox remove`, then marks the run as rolled back.

### 4. Sandbox Environment

Container image: `ghcr.io/nvidia/openshell-community/sandboxes/openclaw:latest`

Inside the sandbox:
- OpenClaw runs with NemoClaw plugin pre-installed.
- Inference calls are routed through OpenShell to the configured provider (never leave sandbox directly).
- Network egress restricted by baseline `openclaw-sandbox.yaml`.
- Isolation: **Landlock LSM** + **seccomp** + **network namespace**.

Filesystem access:

| Path | Access |
|------|--------|
| `/sandbox`, `/tmp`, `/dev/null` | Read-write |
| `/usr`, `/lib`, `/proc`, `/dev/urandom`, `/app`, `/etc`, `/var/log` | Read-only |

Sandbox user: dedicated `sandbox` user and group.

### 5. Inference Routing

```
Agent (sandbox) → OpenShell gateway → NVIDIA cloud (build.nvidia.com)
```

Requests never leave the sandbox directly. OpenShell intercepts every inference call. Default model: `nvidia/nemotron-3-super-120b-a12b` (Nemotron 3 Super 120B, 131K context, 8K output).

Available models via `nvidia-nim` provider:

| Model ID | Context | Max Output |
|----------|---------|------------|
| `nvidia/nemotron-3-super-120b-a12b` | 131,072 | 8,192 |
| `nvidia/llama-3.1-nemotron-ultra-253b-v1` | 131,072 | 4,096 |
| `nvidia/llama-3.3-nemotron-super-49b-v1.5` | 131,072 | 4,096 |
| `nvidia/nemotron-3-nano-30b-a3b` | 131,072 | 4,096 |

Switch at runtime (no restart): `openshell inference set --provider nvidia-nim --model <model-id>`

### 6. Network Policy Enforcement

Deny-by-default. Baseline policy allows specific endpoint groups (see `nemoclaw-network-policy` Cursor rule or `openclaw-sandbox.yaml`). Unknown hosts are blocked and surfaced in the TUI (`openshell term`) for operator approval. Approved endpoints persist for the session only.

### 7. MCP Aggregator Topology

The sandbox reaches four external MCP servers (Kubernetes, Argo CD, Grafana, GitLab) through a single **MCP aggregator** (mcporter) rather than connecting to each directly:

```
Sandbox → (policy-allowed) → MCP Aggregator → kubernetes MCP
                                             → argocd MCP
                                             → grafana MCP
                                             → gitlab MCP
```

Archivist is a separate connection — the sandbox reaches it directly on the host (Docker bridge or LAN IP, depending on networking mode). The aggregator simplifies policy management: one endpoint to allow instead of four.

Configuration lives in `config/mcporter.json` (host-side URLs) and `config/policies/mcp_aggregator.preset.yaml` (sandbox network policy).

### 8. This Repo's Overlay

This challenge repo extends the base NemoClaw design with:
- **Archivist** shared fleet memory (Qdrant + SQLite graph, MCP tools, RBAC namespaces)
- **LiteLLM → Bedrock** as an alternative inference path alongside NVIDIA cloud
- **Five-agent fleet** (Chief, GitBob, Argo, KubeKate, GrafGreg) with per-agent workspaces
- **Custom policy presets** under `config/policies/` for Archivist and MCP aggregator endpoints

## Scripts & References

- `{baseDir}/references/REFERENCE.md` — architecture diagram and file layout cheat sheet.
- Upstream docs: https://docs.nvidia.com/nemoclaw/latest/reference/architecture.html
- Local bootstrap: `docs/NEMOCLAW-NVIDIA-STACK.md`

## Security

- Never bypass digest verification in production; only skip for local dev with a null digest in `blueprint.yaml`.
- Treat sandbox filesystem boundaries as hard limits — do not mount host paths beyond what the compose override requires.
- Inference routing through OpenShell is a security boundary; direct egress to inference endpoints should remain blocked in the network policy.
