# Argo — MCP and Archivist

## MCP (argocd)

| Tool | Use |
|------|-----|
| `list_applications` | Fleet overview |
| `get_application` | Deep dive |
| `sync_application` | Trigger sync (confirm) |
| `get_application_history` | Revisions |
| `rollback_application` | Roll back (confirm) |
| `get_application_manifests` / `get_application_resource_tree` | Rendered state |
| `diff_application` | Live vs desired |

## Archivist

| Field | Value |
|-------|--------|
| `agent_id` | `argo` |
| `namespace` | `deployer` |
