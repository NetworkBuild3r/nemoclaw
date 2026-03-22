---
name: nemoclaw-cli-reference
description: Complete NemoClaw CLI reference — standalone `nemoclaw` commands and `openclaw nemoclaw` plugin commands. Use when running, managing, or scripting NemoClaw sandboxes.
metadata: {"openclaw":{}}
---

# Goal

Provide the correct CLI syntax for every NemoClaw command so agents can operate sandboxes, manage policies, switch models, and debug issues without guessing flags.

## When to Use

- Running any `nemoclaw` or `openclaw nemoclaw` command.
- Scripting sandbox lifecycle (create, connect, destroy).
- Switching inference models or managing policies at runtime.
- Debugging with logs or status checks.

## Instructions

### Standalone Host Commands (`nemoclaw`)

These run outside the sandbox on the host.

| Command | Description |
|---------|-------------|
| `nemoclaw onboard` | Interactive wizard: create gateway, register providers, build sandbox, apply policies. Prompts for NVIDIA API key on first run. |
| `nemoclaw list` | List all registered sandboxes with model, provider, and policy presets. |
| `nemoclaw <name> connect` | Interactive shell into a running sandbox. |
| `nemoclaw <name> status` | Sandbox health, blueprint run state, inference config. |
| `nemoclaw <name> logs [--follow] [-n <count>]` | Stream blueprint + sandbox logs. |
| `nemoclaw <name> destroy` | Stop NIM container and delete sandbox from registry. |
| `nemoclaw <name> policy-add` | Add a policy preset to the sandbox. |
| `nemoclaw <name> policy-list` | List available presets and which are applied. |
| `nemoclaw deploy <instance>` | Deploy to remote GPU via Brev. Experimental. |
| `nemoclaw start` | Start auxiliary services (Telegram bridge, cloudflared). Requires `TELEGRAM_BOT_TOKEN`. |
| `nemoclaw stop` | Stop all auxiliary services. |
| `nemoclaw status` | Sandbox list + auxiliary service status. |
| `nemoclaw setup-spark` | DGX Spark cgroup v2 + Docker fixes. Run with `sudo`. |

Sandbox names must be RFC 1123: lowercase alphanumeric + hyphens, start/end alphanumeric.

### Plugin Commands (`openclaw nemoclaw`)

These run in-process with the OpenClaw gateway.

| Command | Description |
|---------|-------------|
| `openclaw nemoclaw launch [--force] [--profile <p>]` | Bootstrap OpenClaw inside OpenShell sandbox. `--force` skips ergonomics warning. |
| `openclaw nemoclaw status [--json]` | Sandbox health + inference config. `--json` for machine-readable. |
| `openclaw nemoclaw logs [-f] [-n <count>] [--run-id <id>]` | Stream logs. `-f` follows. `--run-id` targets a specific run. |
| `openclaw nemoclaw migrate [--dry-run]` | Pack host config into sandbox. `--dry-run` previews. |

### OpenShell Commands

| Command | Description |
|---------|-------------|
| `openshell term` | TUI for monitoring sandbox + approving egress requests. |
| `openshell policy set <file>` | Apply dynamic policy to running sandbox (session-only). |
| `openshell inference set --provider nvidia-nim --model <id>` | Switch inference model at runtime (no restart). |
| `openshell sandbox list` | List sandboxes from host side. |
| `openshell sandbox upload <name> <src> <dst> [--no-git-ignore]` | Upload files into sandbox. |

### Chat Interface

| Command | Description |
|---------|-------------|
| `/nemoclaw status` | Slash command inside OpenClaw chat TUI. |
| `openclaw tui` | Open interactive chat inside sandbox. |
| `openclaw agent --agent main --local -m "<prompt>" --session-id <id>` | Single CLI message (full output in terminal). |

## Scripts & References

- `{baseDir}/references/REFERENCE.md` — command cheat sheet with common workflows.
- Upstream: https://docs.nvidia.com/nemoclaw/latest/reference/commands.html

## Security

- `nemoclaw onboard` stores NVIDIA API key in `~/.nemoclaw/credentials.json` — never commit this file.
- `nemoclaw deploy` provisions remote VMs with full access — use only with trusted Brev accounts.
- Dynamic policies (`openshell policy set`) are session-only; for permanent changes, edit the baseline YAML.
