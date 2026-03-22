# GrafGreg — MCP and Archivist

## MCP (grafana)

| Tool | Use |
|------|-----|
| `search_dashboards` / `get_dashboard_by_uid` | Locate dashboard |
| `list_datasources` | DS list |
| `query_prometheus` | PromQL (**always specify range**) |
| `list_alert_rules` / `get_alert_instances` | Alerts |
| `get_annotation` / `create_annotation` | Markers / incidents |
| `list_folders` | Browse tree |

## Archivist

| Field | Value |
|-------|--------|
| `agent_id` | `grafgreg` |
| `namespace` | `pipeline` |

Cross-search: also `deployer` when correlating with rollouts (per AGENTS.md).
