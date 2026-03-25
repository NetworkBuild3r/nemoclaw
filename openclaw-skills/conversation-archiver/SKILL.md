---
name: conversation-archiver
description: Auto-archives Cursor conversations to Archivist on session end via Stop hook. Fires after every agent turn; uses an idempotency marker to only archive when the transcript has grown.
hooks:
  Stop:
    - hooks:
      - type: command
        command: "bash \"${CURSOR_SKILL_ROOT:-.cursor/skills/conversation-archiver}/scripts/archive-conversation.sh\""
metadata:
  version: "1.0.0"
---

# Conversation Archiver

Automatically stores a compressed summary of each Cursor conversation into Archivist when the agent finishes a turn. The `Stop` hook runs `archive-conversation.sh`, which:

1. Finds the most recently modified agent transcript JSONL
2. Checks an idempotency marker (`.last-archived`) to skip if already stored at this length
3. Extracts user queries and assistant response summaries into a concise text block
4. Calls `archivist_store` via `scripts/mcp-call.sh` with `agent_id=chief`, `namespace=chief`
5. Updates the marker on success

Fails silently if Archivist is unreachable so it never blocks the user's workflow.
