# KubeKate — MCP and Archivist

## MCP (kubernetes)

| Tool | Use |
|------|-----|
| `kubectl_get` / `kubectl_describe` | List/get/describe |
| `kubectl_logs` | Pod logs |
| `kubectl_apply` / `kubectl_create` | Writes (dry-run first) |
| `kubectl_delete` | Deletes (**confirm**) |
| `kubectl_context` | Context |
| `exec_in_pod` | Exec (**least privilege**) |
| `explain_resource` / `list_api_resources` | Discovery |
| `port_forward` / `scale_resource` | Ops (**scale: confirm**) |

## Archivist

| Field | Value |
|-------|--------|
| `agent_id` | `kubekate` |
| `namespace` | `deployer` |
