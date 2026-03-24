# TOOLS.md — Palo Expert

| **agent_id** | `palo-expert` |
| **Write namespace** | `firewall-ops` |
| **Read** | Search `mcp-engineering`, `skills-research`, `tasks` for context |
| **paloalto MCP** | `mcp-call paloalto panos_show_system_info '{}'`, etc. |
| **archivist** | Store audit lines after each MCP call |

Aggregator base: `MCP_AGGREGATOR` (see `config/mcporter.json`).
