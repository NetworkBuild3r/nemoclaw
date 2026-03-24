---
name: ahead-pan-fleet
description: AHEAD Palo Alto demo agent IDs, Archivist namespaces (tasks, mcp-engineering, skills-research, firewall-ops), and coordination via memory bus — not GitOps Chief/GitBob.
metadata: {"openclaw":{}}
---

# Goal

Run the **AHEAD × Palo Alto** agent slice: **`ahead-chief`**, **`mcp-builder`**, **`researcher`**, **`skill-author`**, **`palo-expert`** — with **Archivist RBAC** from [`config/namespaces.yaml`](../../config/namespaces.yaml).

## Agent → namespace (writes)

| agent_id | Default namespace | Role |
|----------|-------------------|------|
| `ahead-chief` | `tasks` | Task briefs, synthesis; **delegates** `[SKILL-BUILD]` / `[MCP-BUILD]` via same namespace |
| `mcp-builder` | `mcp-engineering` | **Build + push + deploy** MCP servers; see [`mcp-builder`](../mcp-builder/SKILL.md) |
| `skill-builder` | `skill-engineering` | **Author** repo skills under `openclaw-skills/`; see [`skill-builder`](../skill-builder/SKILL.md) |
| `researcher` | `skills-research` | API / doc findings |
| `skill-author` | `skills-research` | Playbooks / SKILL-shaped text |
| `palo-expert` | `firewall-ops` | Audit results |

**Read:** all namespaces allow `read: ["all"]` — any agent can `archivist_search` across the fleet; writes are ACL-limited.

## MCP servers

- **archivist** — message bus.
- **paloalto** — PAN-OS tools (`mcp-call paloalto ...`). URL in [`config/mcporter.json`](../../config/mcporter.json).
- **kubernetes** — **`mcp-builder`** applies [`deploy/k8s/paloalto-mcp`](../../deploy/k8s/paloalto-mcp) after **build + push**.
- **gitlab** — optional; MR + pipeline when CI builds/pushes the image (same `mcp-call gitlab` pattern as GitBob).

## Build and push (mcp-builder)

The demo expects **NemoClaw `mcp-builder`** to drive delivery from [`mcp-servers/paloalto`](../../mcp-servers/paloalto): **docker build + docker push** to your registry, **or** GitLab pipeline producing the image, then **kubectl rollout**. Store proof in **`mcp-engineering`**. OpenShell must allow **registry** (and **GitLab** if used) — see [`config/policies/ahead_pan_sandbox.preset.yaml`](../../config/policies/ahead_pan_sandbox.preset.yaml).

## Team labels

See [`config/team_map.yaml`](../../config/team_map.yaml): `leadership`, `platform-engineering`, `research`, `security-ops`.

## Security

Do not store PAN credentials in Archivist text. Use Vault / env in the runtime that runs `paloalto` MCP (Secret in k8s, or `PANOS_MOCK=1` for dry runs).
