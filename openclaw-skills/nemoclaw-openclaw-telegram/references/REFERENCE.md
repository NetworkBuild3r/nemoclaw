# Telegram routing — troubleshooting checklist

1. **Gateway running?** User service / process that loads Telegram plugin and `tokenFile` paths.
2. **Token file exists?** Run `vault-sync-telegram-tokens.sh` and check permissions (`600`).
3. **Binding match?** `accountId` in the incoming update must match `channels.telegram.accounts` and `bindings` for the intended `agentId`.
4. **Forum topic?** If the chat is a forum thread, confirm `topics.<id>.agentId` and `requireMention` for that thread.
5. **Wrong agent?** Compare group-level defaults vs topic-level overrides; topic wins when configured.
6. **"Something went wrong while processing your request"** (Telegram) with **no** LLM error: check gateway logs (`/tmp/openclaw-*/openclaw-*.log` or `journalctl --user -u openclaw-gateway.service`). A common cause is **`Missing workspace template: AGENTS.md (/opt/openclaw/docs/reference/templates/AGENTS.md)`** — the `/opt/openclaw` install omitted `docs/reference/templates/`. Fix: run `sudo ./scripts/install-openclaw-workspace-templates.sh` from this repo, or ensure `WorkingDirectory` for the gateway is the repo root (`/home/.../nemoclaw`) where `docs/reference/templates/` exists; restart the gateway after fixing.

For OpenClaw JSON schema details and topic session isolation, use the **telegram-topics** Agent Skill if available in your environment.
