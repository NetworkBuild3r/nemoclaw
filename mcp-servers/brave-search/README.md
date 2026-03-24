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
