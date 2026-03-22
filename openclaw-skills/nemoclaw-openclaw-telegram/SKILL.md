---
name: nemoclaw-openclaw-telegram
description: OpenClaw Telegram multi-bot routing (bindings, tokenFile, forum topics, agentId overrides). Use when debugging which bot handles a chat, topic thread isolation, or Vault -> token file sync for the gateway.
metadata: {"openclaw":{}}
---

# OpenClaw Telegram — Multi-Bot Routing for NemoClaw

Route Telegram messages to the right agent via per-account bot tokens, bindings, and forum-topic overrides.

## When to Use

- A message goes to the wrong agent or gets no reply at all.
- Setting up a new Telegram bot account in OpenClaw.
- Understanding `requireMention`, group policies, and `topics` maps.
- Debugging inference failures that look like Telegram problems.
- Restarting or troubleshooting the gateway systemd service.

---

## Architecture

```
Telegram API
    │
    ▼
OpenClaw Gateway  (systemd: openclaw-gateway.service)
    │
    ├── channels.telegram.accounts.<accountId>  ← per-bot token
    │       │
    │       └── groups.<groupId>.topics.<topicId>.agentId  ← routing
    │
    ├── bindings[]  ← (channel, accountId) → agentId
    │
    └── agents.list[].model.primary  ← inference model
```

The gateway long-polls Telegram via grammY for each enabled account. Incoming messages are matched to an agent through **bindings** (for DMs) and **topic-level `agentId`** overrides (for forum groups). The agent runs inference against the configured model and sends the response back through the same bot account.

---

## Config Hierarchy (openclaw.json)

Three levels control Telegram behavior. **Lower levels override higher ones.**

### Level 1: Top-level channel defaults

```jsonc
"channels.telegram.groups.<groupId>"
```

Sets defaults for the entire group across **all** bot accounts. The `requireMention` value here is what OpenClaw reads for the `/status` "Activation" display.

### Level 2: Per-account group settings

```jsonc
"channels.telegram.accounts.<accountId>.groups.<groupId>"
```

Per-bot overrides for the group. Each account can set its own `requireMention`, `enabled`, etc.

### Level 3: Per-topic overrides (within an account)

```jsonc
"channels.telegram.accounts.<accountId>.groups.<groupId>.topics.<topicId>"
```

Topic-level settings: `agentId`, `requireMention`, `groupPolicy`. This is where agent routing happens.

### Critical: requireMention must be set at BOTH levels

OpenClaw reads `requireMention` from **`channels.telegram.groups.<groupId>.topics.<topicId>`** (top-level) for the `/status` display and activation logic. If you only set it under `accounts.<id>.groups`, plain messages may still be ignored.

**Always mirror topic `requireMention` at both:**

1. `channels.telegram.groups."<groupId>".topics."<topicId>".requireMention`
2. `channels.telegram.accounts."<accountId>".groups."<groupId>".topics."<topicId>".requireMention`

---

## Multi-Bot Wiring

### 1. Bot tokens (Vault -> disk)

Each bot has a token file synced from Vault. Never commit tokens.

```
Vault path:    kv/nemoclaw/telegram/<accountId>  (field: token)
Disk path:     ~/.openclaw/secrets/telegram/<accountId>.token  (mode 600)
Sync script:   scripts/vault-sync-telegram-tokens.sh
```

The systemd service runs the sync as `ExecStartPre` on every gateway start.

### 2. Account registration

```jsonc
{
  "channels": {
    "telegram": {
      "accounts": {
        "chief":    { "enabled": true, "tokenFile": "/path/to/chief.token" },
        "gitbob":   { "enabled": true, "tokenFile": "/path/to/gitbob.token" },
        "argo":     { "enabled": true, "tokenFile": "/path/to/argo.token" },
        "kubekate": { "enabled": true, "tokenFile": "/path/to/kubekate.token" },
        "grafgreg": { "enabled": true, "tokenFile": "/path/to/grafgreg.token" }
      }
    }
  }
}
```

### 3. Bindings (DM routing)

```jsonc
{
  "bindings": [
    { "type": "route", "agentId": "chief",    "match": { "channel": "telegram", "accountId": "chief" } },
    { "type": "route", "agentId": "gitbob",   "match": { "channel": "telegram", "accountId": "gitbob" } }
  ]
}
```

A binding maps `(channel=telegram, accountId)` to an `agentId`. Required for DMs. Group/topic routing uses the `topics.<id>.agentId` field instead.

### 4. Topic routing (forum groups)

Under each account, specify which topics that bot handles:

```jsonc
"accounts": {
  "chief": {
    "groups": {
      "-1003828106848": {
        "topics": {
          "1":  { "agentId": "chief",  "requireMention": true,  "groupPolicy": "open" },
          "14": { "agentId": "gitbob", "requireMention": false, "groupPolicy": "open" }
        }
      }
    }
  }
}
```

---

## BotFather Privacy Mode

Telegram's **default bot privacy mode** blocks delivery of plain messages in groups. With privacy enabled, bots only receive `/commands`, `@mentions`, and replies to their own messages.

**Fix:** In Telegram, open **@BotFather** -> `/setprivacy` -> choose **each** bot -> **Disable**.

Repeat for every bot that should see full group traffic. If BotFather already shows "Current status is: DISABLED", privacy is not the problem.

---

## Model Resolution and Stale Sessions

### Model ID format

The model ID in `agents.defaults.model.primary` (and per-agent overrides) must match a model registered under `models.providers`. The format is `<provider>/<model-id>`.

**Correct:** `nvidia/nemotron-3-super-120b-a12b` (matches provider `nvidia`, model id `nvidia/nemotron-3-super-120b-a12b`).

**Wrong:** `nvidia/nvidia/nemotron-3-super-120b-a12b` (double prefix). This can cause `FailoverError: Unknown model` or silent timeouts.

### Session model persistence

Each Telegram session remembers which model it was created with. If the model config changes, **old sessions keep using the old model**. If that old model no longer resolves (provider removed, credentials expired), inference fails silently.

**Fix:** Send `/new@<botname>` in the Telegram topic to reset the session and pick up the current model config.

### Symptoms of model problems

- Bot shows online, receives messages, but never replies
- `/status` shows a model that is not in `models.providers`
- Gateway logs show `FailoverError: Unknown model` or `embedded run timeout`

---

## Gateway Service (systemd)

The OpenClaw gateway runs as a user systemd service.

### Key commands

```bash
systemctl --user status  openclaw-gateway.service   # health check
systemctl --user restart openclaw-gateway.service   # restart after config changes
systemctl --user stop    openclaw-gateway.service   # stop gateway
journalctl --user -u openclaw-gateway.service -f    # tail logs
```

### Service file location

```
~/.config/systemd/user/openclaw-gateway.service
```

### What happens on start

1. `ExecStartPre` runs `vault-sync-telegram-tokens.sh` (Vault -> token files)
2. `ExecStart` runs `node /opt/openclaw/openclaw.mjs gateway`
3. Gateway loads `openclaw.json`, starts Telegram long-polling for each account

### Hot reload

The gateway watches `openclaw.json` for changes and hot-reloads some sections (model providers, agent list). Not all changes hot-reload; restart the service for channel/account/binding changes.

---

## Troubleshooting

### Quick checklist

1. **Gateway running?** `systemctl --user status openclaw-gateway.service`
2. **Token files exist?** `ls -la ~/.openclaw/secrets/telegram/`
3. **Bot privacy disabled?** Check each bot in @BotFather -> `/setprivacy` -> should show "DISABLED"
4. **Model resolves?** Check `journalctl` for `FailoverError: Unknown model`
5. **Session stale?** Send `/new@<botname>` to reset
6. **Binding match?** `accountId` in bindings must match `accounts.<id>` keys
7. **Topic config dual-level?** `requireMention` set at both top-level and account-level

### Log patterns (journalctl)

Search gateway logs for specific issues:

```bash
# Model resolution failures
journalctl --user -u openclaw-gateway.service --since "1h ago" --no-pager | grep "FailoverError"

# Inference timeouts (10-minute default)
journalctl --user -u openclaw-gateway.service --since "1h ago" --no-pager | grep "embedded run timeout"

# Credential failures (Bedrock/LiteLLM leftover sessions)
journalctl --user -u openclaw-gateway.service --since "1h ago" --no-pager | grep "CredentialsProviderError"

# Successful Telegram sends (confirms routing works)
journalctl --user -u openclaw-gateway.service --since "1h ago" --no-pager | grep "sendMessage ok"

# Model fallback decisions
journalctl --user -u openclaw-gateway.service --since "1h ago" --no-pager | grep "model-fallback"

# Session saves (confirms agent ran)
journalctl --user -u openclaw-gateway.service --since "1h ago" --no-pager | grep "session-memory"
```

### Common failure modes

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Bot online but never replies | Model not found / inference timeout | Check model ID, send `/new`, check logs |
| `/status` works but plain messages ignored | BotFather privacy enabled | `/setprivacy` -> Disable for each bot |
| `/status` shows wrong model | Stale session from old config | `/new@<botname>` to reset |
| `CredentialsProviderError` in logs | Session using removed LiteLLM/Bedrock provider | `/new` to reset session model |
| `sendMessage ok` but no visible reply | Message sent to wrong chat/topic | Check topic ID and agentId mapping |
| Gateway crash loop | Wrong node path in systemd | Verify `ExecStart` uses correct `which node` path |

---

## Scripts & References

- `scripts/vault-sync-telegram-tokens.sh` — Vault KV -> token files on disk
- `scripts/telegram-forum-thread-ids.sh` — discover topic IDs via Bot API `getUpdates`
- `docs/vault-telegram-bots.md` — Vault paths, sync procedure, systemd integration
- `{baseDir}/references/REFERENCE.md` — expanded troubleshooting checklist

## Security

- Token files must be mode `600` and never committed.
- Rotating a bot token in Vault requires re-sync and gateway restart.
- Do not paste tokens into skills or tracked config.
- The gateway auth token in `openclaw.json` is for local API access only.
