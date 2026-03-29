# TOOLS.md — Birdman (snow-birdman)

| **agent_id** | `snow-birdman` |
| **Write namespace** | `change-control` |
| **Read** | `chief`, `tasks`, `mcp-engineering`, `deployer` for cross-links to changes |
| **servicenow MCP** | `mcp-call servicenow snow_create_change '…'`, `snow_create_incident '…'`, `--list` |
| **archivist** | Store CHG/INC summaries after each meaningful MCP call |

Aggregator / local URL: see `config/mcporter.json` → `servicenow.url` (often `…/snow/mcp` on the MCP aggregator).
