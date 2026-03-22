# NemoClaw CLI — Quick Reference

## Common Workflows

### Fresh install

```bash
curl -fsSL https://www.nvidia.com/nemoclaw.sh | bash
# or from vendored source:
npm install -g ~/nemoclaw/vendor/NemoClaw
nemoclaw onboard
```

### Daily operations

```bash
nemoclaw my-assistant status           # health check
nemoclaw my-assistant connect          # shell in
nemoclaw my-assistant logs --follow    # stream logs
openshell term                         # TUI for egress approvals
```

### Switch model at runtime

```bash
openshell inference set --provider nvidia-nim --model nvidia/nemotron-3-nano-30b-a3b
openclaw nemoclaw status               # verify switch
```

### Policy management

```bash
nemoclaw my-assistant policy-list                      # see applied presets
nemoclaw my-assistant policy-add                       # add preset interactively
openshell policy set config/policies/archivist.preset.yaml  # dynamic apply
```

### Telegram bridge

```bash
export TELEGRAM_BOT_TOKEN=<token>
export ALLOWED_CHAT_IDS="123456,789012"   # optional restriction
nemoclaw start
nemoclaw status                           # verify services
nemoclaw stop
```

### Remote deployment

```bash
export NEMOCLAW_GPU="a2-highgpu-1g:nvidia-tesla-a100:1"
nemoclaw deploy my-gpu-box
# reconnect: nemoclaw deploy my-gpu-box
# monitor:   ssh my-gpu-box 'openshell term'
```

### Migrate host config into sandbox

```bash
openclaw nemoclaw migrate --dry-run    # preview
openclaw nemoclaw migrate              # execute
```

### Destroy and recreate

```bash
nemoclaw my-assistant destroy
nemoclaw onboard
```

### Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/NVIDIA/NemoClaw/refs/heads/main/uninstall.sh | bash
# flags: --yes, --keep-openshell, --delete-models
```
