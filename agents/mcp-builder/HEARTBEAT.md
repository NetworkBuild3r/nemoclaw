# HEARTBEAT.md

When polled: if **HEARTBEAT.md** lists checks, run them; else **`HEARTBEAT_OK`**.

Suggested checks (optional, keep tiny):

1. `archivist_search` for new **`tasks`** mentioning MCP/PAN.
2. If a deploy is in flight: `mcp-call kubernetes kubectl_get` pods `mcp` / pipeline status via **gitlab**.
