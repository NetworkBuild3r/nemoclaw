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

## Security

Do not commit API keys. Rotate any key pasted into chat.
