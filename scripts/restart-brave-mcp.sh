#!/usr/bin/env bash
# Restart local Brave Search MCP (port 8770) with BRAVE_API_KEY from environment or .env.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${BRAVE_ENV_FILE:-$ROOT/.env}"
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  set +a
fi
if [[ -z "${BRAVE_API_KEY:-}" ]]; then
  echo "BRAVE_API_KEY is empty — set it or add to $ENV_FILE" >&2
  exit 1
fi
if command -v lsof >/dev/null 2>&1; then
  for pid in $(lsof -t -i:8770 -sTCP:LISTEN 2>/dev/null || true); do
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
  done
fi
sleep 1
cd "$ROOT/mcp-servers/brave-search"
nohup python main.py >> /tmp/brave-mcp.log 2>&1 &
echo "Brave MCP started (log: /tmp/brave-mcp.log)"
sleep 2
curl -sS "http://127.0.0.1:8770/health" || true
echo ""
