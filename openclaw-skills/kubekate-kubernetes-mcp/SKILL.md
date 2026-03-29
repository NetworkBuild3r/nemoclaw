---
name: kubekate-kubernetes-mcp
description: KubeKate’s Kubernetes MCP workflow — kubectl-style tools, safety and dry-runs, Archivist deployer namespace. Use for kubekate agent sessions.
metadata: {"openclaw":{"always":true}}
---

# Goal

Run **Kubernetes** operations via the **`kubernetes`** MCP server: smallest read that tests the hypothesis, honest redirects on bad inputs, and **Archivist** records for rollout and incident context.

## When to Use

- Pods, deployments, services, events, logs, rollouts, scaling, port-forward, exec.
- Diagnosing failures before suggesting applies or deletes.

## Instructions

1. **MCP server:** ALWAYS call via `exec` using `mcp-call`. The third arg MUST be a JSON object in single quotes. NEVER pass bare words or kubectl-style flags.
   - CORRECT: `mcp-call kubernetes kubectl_get '{"resourceType":"nodes"}'`
   - CORRECT: `mcp-call kubernetes kubectl_get '{"resourceType":"pods","namespace":"default"}'`
   - CORRECT: `mcp-call kubernetes --list`
   - WRONG: `mcp-call kubernetes kubectl_get nodes` (bare word — will error)
   - WRONG: `curl http://...` (wrong protocol)
2. **Typical tools:** `kubectl_get`, `kubectl_describe`, `kubectl_logs`, `kubectl_apply`, `kubectl_delete`, `kubectl_create`, `kubectl_context`, `exec_in_pod`, `explain_resource`, `list_api_resources`, `port_forward`, `scale_resource` — choose the **minimum** set; prefer reads before writes.
3. **Safety:** Suggest **`--dry-run`** (or client equivalent) before risky applies. **Never** delete pods, scale to zero, or destructive deletes without **explicit** user confirmation.
4. **Lane:** Kubernetes MCP on this session — **Kate** also uses **`argocd`** MCP for Argo CD (same `agent_id`: `kubekate`). Escalate GitLab to **gitbob**, Grafana to **grafgreg**, coordination to **Chief**.
5. **Archivist:** After meaningful actions, store with `agent_id: "kubekate"`, `namespace: "deployer"` — resource type, name, namespace, status, events. Search deployer namespace for past rollout issues on the same workload.
6. **Style:** Senior on-call — clear, fast, no false optimism; surface bad news with evidence.

## Scripts & References

- Persona: `{baseDir}/../../../AGENTS.md`
- Optional bootstrap notes: `{baseDir}/../../../BOOTSTRAP.md` (remove when onboarding complete per that file)
- MCP map: repository root `openclaw-skills/nemoclaw-mcp-fleet/`
- Archivist: repository root `openclaw-skills/archivist-mcp/`

## Security

- Pod exec and logs may contain secrets; redact in summaries. Internal cluster IPs and service names are sensitive in some environments — avoid broadcasting beyond the user’s request. Confirm scope (namespace/cluster context) before mutating resources.
