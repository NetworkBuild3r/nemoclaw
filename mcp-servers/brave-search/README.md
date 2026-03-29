# Brave Search MCP

Exposes **`brave_web_search`** via **streamable HTTP** at **`POST /mcp`** (same style as mcp-aggregator backends).

## Setup

1. Get an API key from [Brave Search API](https://brave.com/search/api/).
2. Set **`BRAVE_API_KEY`** (never commit it). Example:

   ```bash
   export BRAVE_API_KEY='your-key'
   ```

   Or add to **`.env`** in the repo root (gitignored) and load before starting:

   ```bash
   set -a && source /home/bnelson/nemoclaw/.env && set +a
   ```

3. Install and run (default port **8770**):

   ```bash
   cd mcp-servers/brave-search
   pip install -r requirements.txt
   python main.py
   ```

4. **`mcp-call`** uses **`BRAVE_MCP_URL`** (default `http://127.0.0.1:8770/mcp`). Test:

   ```bash
   mcp-call brave --list
   mcp-call brave brave_web_search '{"query":"Palo Alto PAN-OS REST API","count":5}'
   ```

5. Optional: add **`brave`** to [`config/mcporter.json`](../../config/mcporter.json) if your client reads it (point to the same URL or via aggregator).

## Egress

Sandboxes need HTTPS to **`api.search.brave.com:443`** (see [`config/policies/ahead_pan_sandbox.preset.yaml`](../../config/policies/ahead_pan_sandbox.preset.yaml) `brave_search` preset).

## Troubleshooting HTTP **422** from Brave

422 means Brave rejected the request (not auth 401). Common causes:

1. **Wrong or placeholder key** — Use a key from [Brave Search API dashboard](https://api-dashboard.search.brave.com/) (**Web Search** / Search API product), not unrelated Brave keys.
2. **Plan** — Confirm your subscription includes **Web Search** quota (dashboard shows usage/errors).
3. **Query shape** — Pass a **short plain-text** `query` (the `q` param). Pasting multi-KB JSON or “thinking” blocks into `query` often triggers 422. This MCP truncates very long queries (~400 chars).
4. **Process env** — The MCP server must inherit **`BRAVE_API_KEY`** (systemd `EnvironmentFile`, shell `export`, or `.env` loaded **before** `python main.py`). Restart the process after changing the key.
5. **Health** — `curl -s http://127.0.0.1:8770/health` should show `"brave_api_key_configured": true`.

6. **`SUBSCRIPTION_TOKEN_INVALID`** (HTTP 422) — Brave rejected the key. Create or copy a **Web Search** API key from [api-dashboard.search.brave.com](https://api-dashboard.search.brave.com/), update **`BRAVE_API_KEY`** in your secret store (e.g. repo **`.env`**, gitignored), then run **`scripts/restart-brave-mcp.sh`** from the repo root.

After code changes, restart **`python main.py`** (or **`scripts/restart-brave-mcp.sh`**) and retry:

`mcp-call brave brave_web_search '{"query":"test","count":3}'`
