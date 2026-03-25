# MCP server → NemoClaw specialist

| `mcpServers` key | Typical specialist | Notes |
|------------------|-------------------|--------|
| `kubernetes` | KubeKate (`kubekate`) | Pod logs, rollouts, `kubectl_*` tools |
| `argocd` | Argo (`argo`) | Applications, sync, rollback |
| `grafana` | GrafGreg (`grafgreg`) | Dashboards, PromQL, alerts |
| `gitlab` | GitBob (`gitbob`) | MRs, pipelines, issues |
| `archivist` | All agents | `archivist_*` memory tools; pass correct `agent_id` |
| `paloalto` | `palo-expert` | `panos_*` read-only PAN-OS tools |
| `servicenow` | Chief / ops | `snow_create_incident`, `snow_create_change` (Table API) |

**Kubernetes MCP:** runs against the **cluster API** (in-cluster or kubeconfig). SSH to the control-plane host (e.g. `192.168.11.129`) is for **kubectl admin**, not the MCP URL — the URL in `mcporter.json` should still be the **aggregator** path `.../kubernetes/mcp`.

Chief coordinates and does **not** replace these MCP servers — delegates to the right agent.
