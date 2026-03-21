#!/usr/bin/env bash
# Discover Telegram forum topic IDs (message_thread_id) for your supergroup.
# Usage:
#   export TELEGRAM_BOT_TOKEN='...'
#   ./scripts/telegram-forum-thread-ids.sh
#
# Stop the OpenClaw gateway first so it does not consume updates:
#   systemctl --user stop openclaw-gateway.service
#
# Then post one short message in each topic (e.g. "id") and re-run this script.

set -euo pipefail
: "${TELEGRAM_BOT_TOKEN:?Set TELEGRAM_BOT_TOKEN}"
GROUP_ID="${1:--1003828106848}"

export GROUP_ID
curl -sS "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates?limit=100" \
  | python3 -c "
import json, sys, os
gid = int(os.environ['GROUP_ID'])
d = json.load(sys.stdin)
if not d.get('ok'):
    print(d); sys.exit(1)
rows = []
for u in d['result']:
    msg = u.get('message') or {}
    if not msg: continue
    chat = msg.get('chat', {})
    if chat.get('id') != gid:
        continue
    tid = msg.get('message_thread_id')
    text = (msg.get('text') or '')[:80]
    if tid:
        rows.append((tid, text))
    if msg.get('forum_topic_created'):
        ft = msg['forum_topic_created']
        rows.append((tid, 'TOPIC_CREATED:' + ft.get('name','')))
for tid, text in sorted(set(rows)):
    print(f'thread_id={tid}\t{text!r}')
" GROUP_ID="$GROUP_ID"
