#!/usr/bin/env bash
# Quick HTTP reachability checks for URLs in config/mcporter.json.
# Does not validate MCP protocol (use openclaw / mcporter against a live session).
#
# Usage (from repo root):
#   ./scripts/validate-mcp-endpoints.sh
#   MCP_CONFIG=config/mcporter.example.json ./scripts/validate-mcp-endpoints.sh

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="${MCP_CONFIG:-$ROOT/config/mcporter.json}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 required" >&2
  exit 1
fi

python3 <<'PY' "$CFG"
import json, sys, urllib.request, ssl
from urllib.error import HTTPError, URLError

path = sys.argv[1]
with open(path) as f:
    cfg = json.load(f)
servers = cfg.get("mcpServers") or {}
ctx = ssl.create_default_context()
print(f"Config: {path}\n")
for name, meta in sorted(servers.items()):
    url = (meta or {}).get("url")
    if not url:
        print(f"SKIP {name}: no url")
        continue
    try:
        req = urllib.request.Request(url, method="GET", headers={"Accept": "application/json, text/event-stream, */*"})
        with urllib.request.urlopen(req, timeout=6, context=ctx) as r:
            code = r.status
    except HTTPError as e:
        code = e.code
    except URLError as e:
        print(f"FAIL {name}: {url}\n       {e.reason}")
        continue
    except Exception as e:
        print(f"FAIL {name}: {url}\n       {e}")
        continue
    flag = "OK " if code < 400 else "WARN"
    print(f"{flag} {name}: HTTP {code}  {url}")
PY

echo ""
echo "Notes:"
echo "  - GET may return 200/404/405/406 depending on server; FAIL = connection refused / timeout."
echo "  - SSE endpoints (/mcp/sse) often need an MCP client, not raw GET."
echo "  - Fix aggregator 404s by aligning Ingress path with the backend Service (see docs/MCP-AND-MODELS.md)."
