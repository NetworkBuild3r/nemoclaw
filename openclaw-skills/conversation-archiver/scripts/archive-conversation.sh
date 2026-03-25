#!/usr/bin/env bash
# archive-conversation.sh — extract a summary from the most recent Cursor
# agent transcript and store it in Archivist.  Called by the conversation-archiver
# skill's Stop hook.  Fails silently so it never blocks the user.
set -euo pipefail

TRANSCRIPTS_DIR="${CURSOR_TRANSCRIPTS_DIR:-$HOME/.cursor/projects/home-bnelson-nemoclaw/agent-transcripts}"
REPO_ROOT="${CURSOR_REPO_ROOT:-$HOME/nemoclaw}"
MARKER_FILE="${TRANSCRIPTS_DIR}/.last-archived"
MCP_CALL="${REPO_ROOT}/scripts/mcp-call.sh"

export ARCHIVIST_SSE_READ_SECONDS=30

# --- find the most recently modified parent transcript -----------------------

latest_dir=$(find "$TRANSCRIPTS_DIR" -maxdepth 1 -mindepth 1 -type d -printf '%T@ %p\n' 2>/dev/null \
  | sort -rn | head -1 | cut -d' ' -f2-)

[[ -z "${latest_dir:-}" ]] && exit 0

uuid=$(basename "$latest_dir")
transcript="${latest_dir}/${uuid}.jsonl"
[[ -f "$transcript" ]] || exit 0

line_count=$(wc -l < "$transcript")
[[ "$line_count" -lt 2 ]] && exit 0  # nothing meaningful to archive

# --- idempotency check ------------------------------------------------------

if [[ -f "$MARKER_FILE" ]]; then
  prev=$(cat "$MARKER_FILE" 2>/dev/null || true)
  [[ "$prev" == "${uuid}:${line_count}" ]] && exit 0
fi

# --- build summary via Python ------------------------------------------------

summary=$(python3 -c "
import json, sys, re

path = sys.argv[1]
turns = []
with open(path) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        role = obj.get('role', '')
        blocks = obj.get('message', {}).get('content', [])
        text = ' '.join(b.get('text', '') for b in blocks if b.get('type') == 'text')
        if not text:
            continue

        if role == 'user':
            # extract just the <user_query> content if present
            m = re.search(r'<user_query>\s*(.*?)\s*</user_query>', text, re.DOTALL)
            if m:
                text = m.group(1).strip()
            else:
                # skip system-only messages with no user content
                if '<system_reminder>' in text and '<user_query>' not in text:
                    continue
            turns.append(('Q', text[:300]))
        elif role == 'assistant':
            turns.append(('A', text[:200]))

if not turns:
    sys.exit(1)

parts = []
for role, text in turns:
    prefix = 'User: ' if role == 'Q' else 'Assistant: '
    # collapse whitespace
    text = ' '.join(text.split())
    parts.append(prefix + text)

summary = '\n'.join(parts)
# cap at 3000 chars
if len(summary) > 3000:
    summary = summary[:2997] + '...'

print(summary)
" "$transcript" 2>/dev/null) || exit 0

[[ -z "${summary:-}" ]] && exit 0

# --- store in Archivist ------------------------------------------------------

payload=$(python3 -c "
import json, sys
text = sys.argv[1]
uuid = sys.argv[2]
obj = {
    'text': f'Cursor conversation {uuid}:\n{text}',
    'agent_id': 'chief',
    'namespace': 'chief',
    'memory_type': 'experience',
    'importance_score': 0.7,
    'entities': ['cursor-conversation', uuid],
    'force_skip_conflict_check': True
}
print(json.dumps(obj))
" "$summary" "$uuid") || exit 0

if "$MCP_CALL" archivist archivist_store "$payload" >/dev/null 2>&1; then
  echo "${uuid}:${line_count}" > "$MARKER_FILE"
  echo "[conversation-archiver] Archived conversation ${uuid} (${line_count} turns)" >&2
else
  echo "[conversation-archiver] Archivist unreachable — skipped" >&2
fi

exit 0
