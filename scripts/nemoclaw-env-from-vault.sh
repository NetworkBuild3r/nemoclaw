#!/usr/bin/env bash
# Print shell `export` lines for secrets stored in Vault KV `nemoclaw/project-env`.
# Usage:
#   eval "$(./scripts/nemoclaw-env-from-vault.sh)"
#
# Requires Vault auth (same as CLI): nemoclaw/.config/openclaw/vault.env or ~/.vault-token
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEMOCLAW_ROOT="${NEMOCLAW_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
NEMOCLAW_VAULT_ENV="${NEMOCLAW_VAULT_ENV:-$NEMOCLAW_ROOT/.config/openclaw/vault.env}"

if [[ -f "$NEMOCLAW_VAULT_ENV" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$NEMOCLAW_VAULT_ENV"
  set +a
elif [[ -f "${HOME}/.config/openclaw/vault.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${HOME}/.config/openclaw/vault.env"
  set +a
fi

: "${VAULT_ADDR:?Set VAULT_ADDR or add to nemoclaw/.config/openclaw/vault.env}"
: "${VAULT_TOKEN:?Set VAULT_TOKEN or vault login}"

PATH_KV="kv/nemoclaw/project-env"
JSON=$(vault kv get -format=json "$PATH_KV")
echo "$JSON" | python3 -c "
import json, sys, shlex
j = json.load(sys.stdin)
data = j.get('data', {}).get('data', {})
for k, v in data.items():
    if v is None:
        continue
    s = str(v)
    print('export %s=%s' % (k, shlex.quote(s)))
"
