# MCP server → NemoClaw specialist

| `mcpServers` key | Typical specialist | Notes |
|------------------|-------------------|--------|
| `kubernetes` | KubeKate (`kubekate`) | Pod logs, rollouts, `kubectl_*` tools |
| `argocd` | Argo (`argo`) | Applications, sync, rollback |
| `grafana` | GrafGreg (`grafgreg`) | Dashboards, PromQL, alerts |
| `gitlab` | GitBob (`gitbob`) | MRs, pipelines, issues |
| `archivist` | All agents | `archivist_*` memory tools; pass correct `agent_id` |

Chief coordinates and does **not** replace these MCP servers — delegates to the right agent.
