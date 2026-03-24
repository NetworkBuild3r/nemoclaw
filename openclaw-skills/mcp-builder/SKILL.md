---
name: mcp-builder
description: Design and ship HTTP/SSE MCP servers (Python MCP SDK), containerize, push, deploy via k8s + aggregator — for NemoClaw mcp-builder agents and chiefs who delegate MCP work.
metadata: {"openclaw":{}}
---

# Goal

Turn an API or tool surface into an **MCP server** with **streamable HTTP / SSE** compatible with **mcporter** and your **MCP aggregator**, then **build, push, and deploy** to the cluster.

## When to Use

- **`ahead-chief`** assigns a task tagged **`[MCP-BUILD]`** or **`assignee: mcp-builder`** in **`tasks`**.
- **`mcp-builder`** agent implements or extends servers under **`mcp-servers/`**.
- You need a reference pattern beyond a single vendor (e.g. Palo Alto).

## How work is assigned

Pre-configured agent **`mcp-builder`** watches **`tasks`** and writes progress to **`mcp-engineering`**. Chief may also **`sessions_spawn`** with **`agentId: "mcp-builder"`** for isolated MCP work (see [`agents/chief/AGENTS.md`](../../agents/chief/AGENTS.md)). Archivist holds durable status; gateway announce is best-effort. See [`agents/mcp-builder/AGENTS.md`](../../agents/mcp-builder/AGENTS.md).

## Instructions

1. **Transport** — Match existing fleet: **SSE** at `/mcp/sse`, messages under `/mcp/messages/` (see [`archivist-oss/src/main.py`](../../archivist-oss/src/main.py) and [`mcp-servers/paloalto/main.py`](../../mcp-servers/paloalto/main.py)).
2. **Tools** — Implement `mcp.server.Server`, `list_tools` / `call_tool`; return JSON text for PAN/API payloads.
3. **Container** — `Dockerfile` + **readiness** `/health` on the MCP port.
4. **Registry** — `docker build` + `docker push`, **or** GitLab CI pipeline; record image digest/tag in **`mcp-engineering`**.
5. **Cluster** — Kubernetes Deployment + Service; **aggregator** route `/servername/mcp` → Service.
6. **mcporter** — Add `mcpServers.<name>.url` in [`config/mcporter.json`](../../config/mcporter.json).

## Archivist (mcp-builder)

- **agent_id:** `mcp-builder`
- **Write namespace:** `mcp-engineering`

## Scripts & References

- [`nemoclaw-mcp-fleet`](../nemoclaw-mcp-fleet/SKILL.md) — URL patterns
- [`deploy/k8s/paloalto-mcp/README.md`](../../deploy/k8s/paloalto-mcp/README.md) — deploy example
- [`config/policies/ahead_pan_sandbox.preset.yaml`](../../config/policies/ahead_pan_sandbox.preset.yaml) — registry/GitLab egress

## Security

Do not embed API keys in MCP server code; use **Secrets** / env. Restrict OpenShell egress to API hosts and registry only.
