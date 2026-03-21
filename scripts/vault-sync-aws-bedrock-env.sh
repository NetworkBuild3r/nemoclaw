#!/usr/bin/env bash
# Pull AWS credentials for Amazon Bedrock from Vault KV into a systemd EnvironmentFile.
#
# Vault layout (KV v2, mount: kv):
#   kv/nemoclaw/project-env   fields (at minimum):
#     AWS_ACCESS_KEY_ID
#     AWS_SECRET_ACCESS_KEY
#   optional:
#     AWS_SESSION_TOKEN
#     AWS_REGION or AWS_DEFAULT_REGION  (default: us-east-1)
#
# Output (mode 600):
#   <repo>/.config/openclaw/aws-bedrock.env  (canonical; ~/.config/openclaw may symlink here)
#
# Usage:
#   ./scripts/vault-sync-aws-bedrock-env.sh
#
# Requires: same Vault auth as vault-sync-telegram-tokens.sh (nemoclaw/.config/openclaw/vault.env)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEMOCLAW_ROOT="${NEMOCLAW_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
VAULT_KV_MOUNT="${VAULT_KV_MOUNT:-kv}"
PATH_KV="${VAULT_KV_MOUNT}/nemoclaw/project-env"
OUT_FILE="${AWS_BEDROCK_ENV_FILE:-$NEMOCLAW_ROOT/.config/openclaw/aws-bedrock.env}"
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

if ! command -v vault >/dev/null 2>&1; then
  echo "vault CLI not found in PATH" >&2
  exit 1
fi

: "${VAULT_ADDR:?Set VAULT_ADDR (e.g. in nemoclaw/.config/openclaw/vault.env)}"
: "${VAULT_TOKEN:?Set VAULT_TOKEN or run vault login}"

mkdir -p "$(dirname "$OUT_FILE")"
vault kv get -format=json "$PATH_KV" | python3 -c '
import json, os, sys

out = sys.argv[1]
path_kv = sys.argv[2]
j = json.load(sys.stdin)
data = j.get("data", {}).get("data", {})

def req(key):
    v = data.get(key)
    if v is None or str(v).strip() == "":
        return None
    return str(v).strip()

ak = req("AWS_ACCESS_KEY_ID")
sk = req("AWS_SECRET_ACCESS_KEY")
if not ak or not sk:
    try:
        os.unlink(out)
    except OSError:
        pass
    print(
        "vault-sync-aws-bedrock-env: warning: missing AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY in",
        path_kv,
        "(Bedrock disabled until patched; gateway still starts)",
        file=sys.stderr,
    )
    sys.exit(0)

region = req("AWS_REGION") or req("AWS_DEFAULT_REGION") or "us-east-1"
lines = [
    f"AWS_ACCESS_KEY_ID={ak}",
    f"AWS_SECRET_ACCESS_KEY={sk}",
    f"AWS_REGION={region}",
    f"AWS_DEFAULT_REGION={region}",
]
tok = req("AWS_SESSION_TOKEN")
if tok:
    lines.append(f"AWS_SESSION_TOKEN={tok}")

content = "\n".join(lines) + "\n"
fd = os.open(out, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
try:
    os.write(fd, content.encode())
finally:
    os.close(fd)
print(f"wrote {out}")
' "$OUT_FILE" "$PATH_KV"

echo "vault-sync-aws-bedrock-env: ok"
