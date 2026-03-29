# Chief-only forum group (one bot, topic = session)

This deployment uses **one Telegram bot (Chief)** in the forum supergroup. Every topic is routed to agent `chief`; OpenClaw keeps **separate session files per topic** (`session-chief-topic-<id>.jsonl`). Other fleet bots stay available for **private DMs** via `bindings` but do not use `channels.telegram.accounts.<id>.groups` for this group.

## Manual checklist (Telegram app)

1. Remove GitBob, Kate, GrafGreg, and any other bots from **this** supergroup so only the **Chief** bot remains (or ensure they are not members).
2. In **@BotFather**, `/setprivacy` → choose the Chief bot → **Disable** (so plain messages in topics are delivered).

## New topic = new session (no manual topic id)

Stock OpenClaw only matches **exact** `message_thread_id` keys under `topics`. This repo uses a **local patch** to the OpenClaw install plus a **wildcard topic** in config:

1. **`topics["*"]`** — Default routing for any forum thread id not listed explicitly. Set `agentId` and `requireMention` (and under `accounts.chief`, `groupPolicy`).
2. **`topics["1"]`** — Optional override for **General** (often `requireMention: true` while `*` stays `false`).
3. **Patch** — [`scripts/patch-openclaw-telegram-topic-wildcard.sh`](../scripts/patch-openclaw-telegram-topic-wildcard.sh) updates `/opt/openclaw/dist/*.js` so lookups use `topics[exactId] ?? topics["*"]`. **Re-run after every OpenClaw upgrade** (upgrades overwrite `dist/`).

After that, create a new topic in Telegram and chat: Chief gets a **new session per topic** automatically.

### Optional: per-topic overrides

Add a numeric key `"1234"` under `topics` if one thread needs different `requireMention` than `*`.

### Legacy: discover a topic id (debug)

[`scripts/telegram-forum-thread-ids.sh`](../scripts/telegram-forum-thread-ids.sh) — only needed if you are debugging routing.

## Reference

- Skill: `openclaw-skills/nemoclaw-openclaw-telegram/SKILL.md`
- Vault tokens: `docs/vault-telegram-bots.md`
