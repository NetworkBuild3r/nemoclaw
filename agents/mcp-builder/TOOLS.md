# TOOLS.md — MCP Builder

| Item | Value |
|------|--------|
| **agent_id** | `mcp-builder` |
| **Write namespace** | `mcp-engineering` |
| **Read** | `tasks`, `skills-research`, `mcp-engineering` |
| **kubernetes MCP** | Deploy / rollout / `kubectl_get` — **primary** for apply |
| **gitlab MCP** | MR + pipeline status when CI builds/pushes the image |
| **archivist** | Status of the bus |
| **paloalto** | Smoke-test after deploy (`--list`, `panos_show_system_info` with mock) |
| **Skills** | `skills/mcp-builder/SKILL.md` |

## Repo paths

- [`mcp-servers/paloalto/Dockerfile`](../../mcp-servers/paloalto/Dockerfile) — build context root **`mcp-servers/paloalto`**
- [`deploy/k8s/paloalto-mcp/`](../../deploy/k8s/paloalto-mcp/) — Namespace `mcp`, Service port `8765`

## Registry / GitLab (fill for your lab)

| Secret / config | Purpose |
|-----------------|--------|
| `REGISTRY` / image name | Target for **`docker push`** or CI |
| GitLab `project_id` | Pipeline + MR calls |
| Aggregator backend | Route `/paloalto` → `paloalto-mcp:8765` on the cluster |

Do not paste registry passwords into Archivist; reference Vault / env paths only.
