---
name: brave-search
description: Brave Search web search via MCP (brave_web_search) — run mcp-servers/brave-search with BRAVE_API_KEY; use mcp-call brave.
metadata: {"openclaw":{}}
---

# Goal

Use **`mcp-call brave brave_web_search`** for internet search. Server: [`mcp-servers/brave-search`](../../mcp-servers/brave-search) (**streamable HTTP** at `/mcp`, port 8770).

## Setup

1. API key from [Brave Search API](https://brave.com/search/api/).
2. `export BRAVE_API_KEY=...` (or `.env`, gitignored).
3. `python mcp-servers/brave-search/main.py` (port **8770**).
4. Optional: `BRAVE_MCP_URL` if not localhost.

## Example

```bash
mcp-call brave brave_web_search '{"query":"NVIDIA NemoClaw sandbox","count":5}'
```

## If Brave returns **422**

- Use a **Web Search** API key from [api-dashboard.search.brave.com](https://api-dashboard.search.brave.com/) — confirm plan/quota.
- Keep **`query`** short plain text (no pasted JSON blobs); agents must not stuff tool output into `q`.
- Ensure **`BRAVE_API_KEY`** is in the environment of the **MCP process** (restart after changing). See **`mcp-servers/brave-search/README.md`** — Troubleshooting.

## Security

Do not commit API keys. Rotate any key pasted into chat.
