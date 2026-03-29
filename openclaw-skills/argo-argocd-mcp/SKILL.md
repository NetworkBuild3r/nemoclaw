---
name: argo-argocd-mcp
description: Argo CD MCP workflow — apps, sync, health, history, rollback — plus Archivist deployer namespace. Use for Kate (`kubekate`) sessions (same agent as Kubernetes).
metadata: {"openclaw":{"always":true}}
---

# Goal

Operate **Argo CD** through the **`argocd`** MCP server with **read-first** discipline, structured reporting (app, sync, health, revision), and **memory** in Archivist’s deployer namespace.

## When to Use

- Listing or inspecting applications, diffs, manifests, resource trees.
- Reviewing sync status, health, or deployment history.
- Considering sync, rollback, or other state-changing actions (always confirm first).

## Instructions

1. **MCP server:** ALWAYS call via `exec` using `mcp-call`. The third arg MUST be a JSON object in single quotes. NEVER pass bare words.
   - CORRECT: `mcp-call argocd list_applications '{}'`
   - CORRECT: `mcp-call argocd get_application '{"name":"my-app"}'`
   - CORRECT: `mcp-call argocd --list`
   - WRONG: `mcp-call argocd list_applications` (missing JSON arg — will error)
   - WRONG: `curl http://...` (wrong protocol)
2. **Typical tools:** `argocd_list_applications`, `argocd_get_application`, `argocd_sync_application`, `argocd_get_application_history`, `argocd_rollback_application`, `argocd_get_application_manifests`, `argocd_get_application_resource_tree`, `argocd_diff_application` — prefer the **smallest** read set before mutating state.
3. **Truth over comfort:** Cite diff/history when explaining health; say when sync alone will not fix a problem.
4. **Destructive / prod-impacting:** Confirm with the user before sync-force, rollback, or delete-class operations; one sentence on risk.
5. **Lane:** Argo CD (Kate also owns raw **kubernetes** MCP for cluster ops — see `kubekate-kubernetes-mcp`). Hand off GitLab to **gitbob**, Grafana to **grafgreg**.
6. **Archivist:** Store with `agent_id: "kubekate"`, `namespace: "deployer"` — include app name, sync/health, revision, images when relevant. Search deployer namespace before recommending rollback patterns.

## Scripts & References

- Persona: `{baseDir}/../../../AGENTS.md`
- MCP map: repository root `openclaw-skills/nemoclaw-mcp-fleet/`
- Archivist: repository root `openclaw-skills/archivist-mcp/`

## Security

- Application names and revision metadata can imply environment and blast radius. Do not expose internal URLs or credentials from manifests. Treat rollback and sync as production-impacting unless the user scopes otherwise.
