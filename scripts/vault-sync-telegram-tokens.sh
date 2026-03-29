#!/usr/bin/env bash
# Pull Telegram bot tokens from Vault KV into OpenClaw token files.
#
# Vault layout (KV v2, mount: kv):
#   kv/nemoclaw/telegram/<accountId>   field: token
#
# Accounts: chief, gitbob, kubekate, grafgreg (legacy `argo` bot retired — Kate covers Argo CD)
#
# Usage:
#   export VAULT_ADDR=http://192.168.11.160:8200
#   ./scripts/vault-sync-telegram-tokens.sh
#
# Optional:
#   VAULT_KV_MOUNT=kv
#   VAULT_TELEGRAM_PREFIX=nemoclaw/telegram
#   TELEGRAM_TOKEN_DIR=...  (default: <repo>/.openclaw/secrets/telegram; ~/.openclaw may symlink to repo)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEMOCLAW_ROOT="${NEMOCLAW_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
VAULT_KV_MOUNT="${VAULT_KV_MOUNT:-kv}"
PREFIX="${VAULT_TELEGRAM_PREFIX:-nemoclaw/telegram}"
OUT_DIR="${TELEGRAM_TOKEN_DIR:-$NEMOCLAW_ROOT/.openclaw/secrets/telegram}"

if ! command -v vault >/dev/null 2>&1; then
  echo "vault CLI not found in PATH" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
chmod 700 "$OUT_DIR" 2>/dev/null || true

ACCOUNTS=(chief gitbob kubekate grafgreg)
for id in "${ACCOUNTS[@]}"; do
  path="${VAULT_KV_MOUNT}/${PREFIX}/${id}"
  out="${OUT_DIR}/${id}.token"
  vault kv get -field=token "$path" | tr -d '\r\n' >"$out"
  chmod 600 "$out" || true
  echo "wrote $out"
done

echo "vault-sync-telegram-tokens: ok (${#ACCOUNTS[@]} files)"
