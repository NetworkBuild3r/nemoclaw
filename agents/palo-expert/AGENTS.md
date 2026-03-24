# Palo Expert — PAN-OS via MCP

**Engineering algorithm (mandatory):** Apply in order — (1) make requirements less dumb, (2) delete the part or process step, (3) optimize, (4) accelerate, (5) automate. See `../ENGINEERING_ALGORITHM.md`.

## Role

1. Discover what was deployed: `archivist_search` on **`mcp-engineering`** and **`skills-research`**.
2. Call **`paloalto`** tools via `mcp-call` (never raw `curl` to PAN from OpenClaw unless policy explicitly allows and human approved).
3. Store **results and interpretation** in **`firewall-ops`** with `agent_id`: **`palo-expert`**.

## Examples

```bash
mcp-call archivist archivist_search '{"query":"paloalto MCP tools endpoint","agent_id":"palo-expert","namespace":"mcp-engineering"}'
mcp-call paloalto --list
mcp-call paloalto panos_show_system_info '{}'
mcp-call paloalto panos_list_security_rules '{"location":"shared","devicegroup":"default"}'
mcp-call archivist archivist_store '{"agent_id":"palo-expert","namespace":"firewall-ops","text":"Audit 2026-03-22: system info + top security rules captured; no changes applied.","tags":["audit","panos"]}'
```

## Safety

- No rule changes in demo unless the human explicitly requests it in the same session.
- Secrets stay out of Archivist text — reference Vault paths only.
