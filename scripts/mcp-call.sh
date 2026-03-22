#!/usr/bin/env bash
# mcp-call — call an MCP tool via JSON-RPC over HTTP.
#
# Usage:
#   mcp-call <server> <tool> '{"key":"value"}'
#   mcp-call <server> --list
#
# Examples:
#   mcp-call kubernetes kubectl_get '{"resourceType":"nodes"}'
#   mcp-call kubernetes kubectl_get '{"resourceType":"pods","namespace":"default"}'
#   mcp-call argocd list_applications '{}'
#   mcp-call grafana search_dashboards '{"query":""}'
#   mcp-call gitlab list_projects '{}'
#   mcp-call archivist archivist_search '{"query":"cluster health","agent_id":"kubekate"}'
#   mcp-call kubernetes --list
#   mcp-call archivist --list
#
# Servers: kubernetes, argocd, grafana, gitlab, archivist

set -euo pipefail

MCP_AGGREGATOR="${MCP_AGGREGATOR:-http://192.168.11.160:8080}"
ARCHIVIST_URL="${ARCHIVIST_URL:-http://192.168.11.142:3100}"

# --- helpers ----------------------------------------------------------------

die() { echo "Error: $*" >&2; exit 1; }

resolve_url() {
  local server="$1"
  case "$server" in
    archivist) echo "$ARCHIVIST_URL" ;;
    *)         echo "${MCP_AGGREGATOR}/${server}/mcp" ;;
  esac
}

is_json() {
  python3 -c "import json,sys; json.loads(sys.argv[1])" "$1" 2>/dev/null
}

# --- streamable-http call (aggregator servers) ------------------------------

call_streamable() {
  local url="$1" method="$2" payload="$3"
  local response
  response=$(curl -sf --max-time 15 -X POST "$url" \
    -H "Content-Type: application/json" \
    -d "$payload" 2>/dev/null) || die "no response from $url — is the server running?"

  [[ -z "$response" ]] && die "empty response from $url"

  python3 -c "
import sys, json
try:
    d = json.loads(sys.argv[1])
except json.JSONDecodeError:
    print('Error: server returned non-JSON: ' + sys.argv[1][:120], file=sys.stderr)
    sys.exit(1)
if 'error' in d:
    e = d['error']
    print(f\"MCP Error {e.get('code','')}: {e.get('message','')}\", file=sys.stderr)
    sys.exit(1)
if 'result' not in d:
    print('Error: unexpected response (no result key)', file=sys.stderr)
    sys.exit(1)
result = d['result']
if 'tools' in result:
    for t in result['tools']:
        desc = t.get('description','')[:80]
        print(f\"  {t['name']:30s} {desc}\")
elif 'content' in result:
    for item in result['content']:
        if item.get('type') == 'text':
            print(item['text'])
else:
    print(json.dumps(result, indent=2))
" "$response"
}

# --- SSE call (archivist) ---------------------------------------------------

call_sse() {
  local base_url="$1" method="$2" payload="$3"

  python3 -c "
import subprocess, json, time, sys, os

BASE = sys.argv[1]
METHOD = sys.argv[2]
PAYLOAD = json.loads(sys.argv[3])

sse = subprocess.Popen(['curl', '-sN', BASE + '/mcp/sse'],
                        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)

# get session URL
msg_url = None
for raw in sse.stdout:
    line = raw.decode().strip()
    if line.startswith('data:'):
        msg_url = BASE + line[5:].strip()
        break
if not msg_url:
    print('Error: could not establish SSE session with ' + BASE, file=sys.stderr)
    sse.kill(); sys.exit(1)

def post(body):
    subprocess.run(['curl', '-s', '-X', 'POST', msg_url,
                     '-H', 'Content-Type: application/json',
                     '-d', json.dumps(body)],
                    capture_output=True, timeout=10)

def read(timeout_s=10):
    fd = sse.stdout.fileno()
    os.set_blocking(fd, False)
    end = time.time() + timeout_s
    buf = b''
    while time.time() < end:
        try:
            chunk = sse.stdout.read(8192)
            if chunk: buf += chunk
            else: time.sleep(0.1)
        except (BlockingIOError, TypeError):
            time.sleep(0.1)
    os.set_blocking(fd, True)
    out = []
    for ln in buf.decode(errors='replace').split('\n'):
        if ln.startswith('data:'):
            try: out.append(json.loads(ln[5:].strip()))
            except: pass
    return out

# handshake
post({'jsonrpc':'2.0','method':'initialize',
      'params':{'protocolVersion':'2024-11-05','capabilities':{},
                'clientInfo':{'name':'mcp-call','version':'1.0'}},'id':1})
read(3)
post({'jsonrpc':'2.0','method':'notifications/initialized'})
time.sleep(0.3)

# actual request
req_id = 2
if METHOD == 'tools/list':
    post({'jsonrpc':'2.0','method':'tools/list','id': req_id})
else:
    post({'jsonrpc':'2.0','method':'tools/call',
          'params':{'name': PAYLOAD.pop('__tool__'), 'arguments': PAYLOAD},
          'id': req_id})

msgs = read(10)
found = False
for m in msgs:
    if m.get('id') != req_id:
        continue
    found = True
    if 'error' in m:
        e = m['error']
        print(f\"MCP Error {e.get('code','')}: {e.get('message','')}\", file=sys.stderr)
        sse.kill(); sys.exit(1)
    result = m.get('result', {})
    if 'tools' in result:
        for t in result['tools']:
            desc = t.get('description','')[:80]
            print(f\"  {t['name']:30s} {desc}\")
    elif 'content' in result:
        for item in result['content']:
            if item.get('type') == 'text':
                print(item['text'])
    else:
        print(json.dumps(result, indent=2))

if not found:
    print('Error: no response received from Archivist', file=sys.stderr)
    sse.kill(); sys.exit(1)

sse.kill()
" "$base_url" "$method" "$payload"
}

# --- argument parsing -------------------------------------------------------

if [[ $# -lt 2 ]]; then
  echo "Usage: mcp-call <server> <tool> '{\"key\":\"value\"}'"
  echo "       mcp-call <server> --list"
  echo ""
  echo "Servers: kubernetes, argocd, grafana, gitlab, archivist"
  echo ""
  echo "The third argument MUST be a JSON object. Examples:"
  echo "  mcp-call kubernetes kubectl_get '{\"resourceType\":\"nodes\"}'"
  echo "  mcp-call argocd list_applications '{}'"
  echo "  mcp-call archivist archivist_search '{\"query\":\"hello\",\"agent_id\":\"kubekate\"}'"
  exit 1
fi

SERVER="$1"
TOOL="$2"
shift 2
EMPTY_OBJ='{}'
ARGS="${1:-$EMPTY_OBJ}"

# Validate JSON argument
if [[ "$TOOL" != "--list" ]]; then
  if ! is_json "$ARGS"; then
    die "argument '$ARGS' is not valid JSON.
Expected: mcp-call $SERVER $TOOL '{\"key\":\"value\"}'
Example:  mcp-call kubernetes kubectl_get '{\"resourceType\":\"nodes\"}'"
  fi
fi

# --- dispatch ---------------------------------------------------------------

URL=$(resolve_url "$SERVER")

if [[ "$TOOL" == "--list" ]]; then
  PAYLOAD='{"jsonrpc":"2.0","method":"tools/list","id":1}'
  if [[ "$SERVER" == "archivist" ]]; then
    call_sse "$URL" "tools/list" "$PAYLOAD"
  else
    call_streamable "$URL" "tools/list" "$PAYLOAD"
  fi
else
  if [[ "$SERVER" == "archivist" ]]; then
    MERGED=$(python3 -c "
import json, sys
args = json.loads(sys.argv[1])
args['__tool__'] = sys.argv[2]
print(json.dumps(args))
" "$ARGS" "$TOOL")
    call_sse "$URL" "tools/call" "$MERGED"
  else
    PAYLOAD=$(python3 -c "
import json, sys
tool = sys.argv[1]
args = json.loads(sys.argv[2])
print(json.dumps({'jsonrpc':'2.0','method':'tools/call','params':{'name':tool,'arguments':args},'id':1}))
" "$TOOL" "$ARGS") || die "failed to build request payload"
    call_streamable "$URL" "tools/call" "$PAYLOAD"
  fi
fi
