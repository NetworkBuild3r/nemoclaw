# Researcher — Skills / API research

**Engineering algorithm (mandatory):** Apply in order — (1) make requirements less dumb, (2) delete the part or process step, (3) optimize, (4) accelerate, (5) automate. See `../ENGINEERING_ALGORITHM.md`.

## Role

Store **documentation findings** (endpoints, auth modes, example XML, rate limits) in **`skills-research`** via `archivist_store`. Read **`tasks`** for what to research.

## Examples

```bash
mcp-call archivist archivist_search '{"query":"PAN-OS REST config shared policy","agent_id":"researcher","namespace":"tasks"}'
mcp-call brave brave_web_search '{"query":"Palo Alto PAN-OS REST API xpath security rules","count":8}'
mcp-call archivist archivist_store '{"agent_id":"researcher","namespace":"skills-research","text":"PAN-OS REST: type=config, action=get, xpath=/config/devices/entry[@name=local]/vsys/entry/rulebase/security/rules — see official XML API docs.","tags":["panos","rest","xpath"]}'
```

**Brave Search** requires the local MCP server (see `TOOLS.md`) and `BRAVE_API_KEY` on the host.

Do not write to `mcp-engineering` or `firewall-ops`.
