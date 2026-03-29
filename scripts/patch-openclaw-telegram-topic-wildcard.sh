#!/usr/bin/env bash
# Apply local patches to OpenClaw so forum topics fall back to topics["*"] when the
# thread id is not listed. Required for "new topic = new session" without editing JSON.
#
# Re-run after every OpenClaw upgrade (npm / package update overwrites /opt/openclaw/dist).
#
# Usage:
#   sudo bash scripts/patch-openclaw-telegram-topic-wildcard.sh
#   # or as root if your OpenClaw install lives elsewhere:
#   OPENCLAW_ROOT=/opt/openclaw bash scripts/patch-openclaw-telegram-topic-wildcard.sh

set -euo pipefail
ROOT="${OPENCLAW_ROOT:-/opt/openclaw/dist}"
if [[ ! -d "$ROOT" ]]; then
  echo "OpenClaw dist not found: $ROOT" >&2
  exit 1
fi

mapfile -t FILES < <(find "$ROOT" -maxdepth 2 -name '*.js' -type f 2>/dev/null | sort)

patch_file() {
  local f="$1"
  grep -q 'groupConfig?.topics?.\[String(messageThreadId)\] ?? groupConfig?.topics?\.\["\*"\]' "$f" 2>/dev/null && return 0

  if grep -q 'topicConfig: messageThreadId != null ? groupConfig?.topics?.\[String(messageThreadId)\] : void 0' "$f"; then
    sed -i \
      -e 's/topicConfig: messageThreadId != null ? directConfig.topics?.\[String(messageThreadId)\] : void 0/topicConfig: messageThreadId != null ? (directConfig.topics?.[String(messageThreadId)] ?? directConfig.topics?.["*"]) : void 0/g' \
      -e 's/topicConfig: messageThreadId != null ? groupConfig?.topics?.\[String(messageThreadId)\] : void 0/topicConfig: messageThreadId != null ? (groupConfig?.topics?.[String(messageThreadId)] ?? groupConfig?.topics?.["*"]) : void 0/g' \
      "$f"
    echo "patched resolveTelegramGroupConfig: $f"
  fi

  if grep -q 'groupConfig\.topics\[topicId\] : void 0' "$f" && grep -q 'function resolveTelegramRequireMention' "$f"; then
    sed -i \
      -e 's/const topicConfig = topicId && groupConfig?.topics ? groupConfig.topics\[topicId\] : void 0;/const topicConfig = topicId \&\& groupConfig?.topics ? (groupConfig.topics[topicId] ?? groupConfig.topics["*"]) : void 0;/g' \
      -e 's/const defaultTopicConfig = topicId && groupDefault?.topics ? groupDefault.topics\[topicId\] : void 0;/const defaultTopicConfig = topicId \&\& groupDefault?.topics ? (groupDefault.topics[topicId] ?? groupDefault.topics["*"]) : void 0;/g' \
      "$f"
    echo "patched resolveTelegramRequireMention: $f"
  fi
}

for f in "${FILES[@]}"; do
  patch_file "$f" || true
done

echo "Done. Restart gateway: systemctl --user restart openclaw-gateway.service"
