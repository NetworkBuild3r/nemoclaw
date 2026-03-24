# AHEAD Palo Alto demo — runbook

## Archivist config reload

After changing [`config/namespaces.yaml`](../config/namespaces.yaml) or [`config/team_map.yaml`](../config/team_map.yaml), restart the Archivist container so RBAC reloads:

```bash
# From the compose project that mounts ../config -> /data/archivist/config
docker compose restart archivist
```

## MCP: Palo Alto server

- Code: [`mcp-servers/paloalto`](../mcp-servers/paloalto)
- **Mock mode (no firewall):** `PANOS_MOCK=1` (default in k8s Deployment).
- **Live PAN-OS:** set `PANOS_MOCK=0`, `PANOS_HOST`, `PANOS_API_KEY` (or user/password per `panos_client.py`).

Point **mcp-aggregator** at the Service (`paloalto-mcp:8765`) so [`config/mcporter.json`](../config/mcporter.json) `paloalto.url` resolves.

## NemoClaw agents build and push (required narrative)

**`mcp-builder`** is responsible for **build → push → deploy**, not only kubectl apply of a fixed image. Acceptable implementations:

1. **Direct:** `docker build` / `docker push` from code under [`mcp-servers/paloalto`](../mcp-servers/paloalto), then patch the Deployment image and **`kubectl apply`** (via **kubernetes** MCP).
2. **CI:** Commit/MR + **gitlab** MCP pipeline until the image exists in registry, then point the Deployment at that tag and roll out.

Evidence must land in Archivist **`mcp-engineering`**: image ref (and digest or CI link), commit SHA, rollout confirmation.

Ensure the **mcp-builder** sandbox policy allows **container registry** (e.g. `ghcr.io`, your Harbor) and, if used, **GitLab API** — see [`config/policies/ahead_pan_sandbox.preset.yaml`](../config/policies/ahead_pan_sandbox.preset.yaml) (`container_registry`, `gitlab_api`).

## NemoClaw sandbox matrix (egress)

Use [`config/policies/ahead_pan_sandbox.preset.yaml`](../config/policies/ahead_pan_sandbox.preset.yaml) as a base. Per persona:

| Persona | archivist:3100 | aggregator:8080 | Nemotron API | registry :443 | GitLab API :443 | PAN MGMT :443 |
|---------|----------------|------------------|--------------|---------------|-----------------|---------------|
| ahead-chief | yes | yes | yes | no | optional | no |
| mcp-builder | yes | yes | yes | **yes** | **if CI** | no |
| skill-builder | yes | optional | yes | no | **if MR** | no |
| researcher | yes | optional | yes | no | optional | no |
| skill-author | yes | optional | yes | no | optional | no |
| palo-expert | yes | yes | yes | no | no | **yes** (replace `REPLACE_WITH_PAN_MGMT_HOSTNAME`) |

**Blocked egress shot:** add a policy rule for a forbidden host and show OpenShell deny in logs.

## Dry-run checklist (2–3 clean passes)

1. **ahead-chief:** `archivist_store` a task into `tasks` with **done-when** including image push + rollout (see [`agents/ahead-chief/AGENTS.md`](../agents/ahead-chief/AGENTS.md)).
2. **researcher** (optional): store a doc snippet into `skills-research`.
3. **mcp-builder:** **build and push** the image (or drive GitLab CI to do it), **apply** manifests, smoke `mcp-call paloalto --list`, then **`archivist_store`** proof in `mcp-engineering`.
4. **palo-expert:** `mcp-call paloalto panos_show_system_info '{}'` then `archivist_store` audit into `firewall-ops`.
5. **ahead-chief:** `archivist_insights` or cross-namespace `archivist_search` for synthesis.

For the video, you may **pre-stage** the aggregator route or a long CI run; still show **one** real **`docker push` or pipeline success** + **`paloalto` tool** call on camera.

## OpenClaw agents

Registered in [`.openclaw/openclaw.json`](../.openclaw/openclaw.json) with workspaces under `agents/{ahead-chief,mcp-builder,researcher,skill-author,palo-expert}/`.

Demo agents use **`nvidia/nemotron-3-super-120b-a12b`**. If `NVIDIA_API_KEY` is unset, switch their `model.primary` to `litellm-local/openclaw-haiku` (or your LiteLLM route) for local testing.
