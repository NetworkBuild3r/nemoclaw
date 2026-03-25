# Palo Alto MCP on Kubernetes

The MCP server code lives in [`mcp-servers/paloalto`](../../mcp-servers/paloalto). It exposes **SSE** at `/mcp/sse` (same shape as Archivist) for compatibility with **mcporter** and your **MCP aggregator**.

## Build and push

**Intended flow:** the **`mcp-builder`** NemoClaw agent (see [`agents/mcp-builder/AGENTS.md`](../../../agents/mcp-builder/AGENTS.md)) performs **`docker build` / `docker push`** (or triggers GitLab CI), updates the image reference, and applies this manifest via the **kubernetes** MCP. Humans can run the same commands for debugging.

```bash
cd mcp-servers/paloalto
docker build -t your-registry/paloalto-mcp:latest .
docker push your-registry/paloalto-mcp:latest
```

Edit `deployment.yaml` image and Secret `panos-credentials` (API key or leave `PANOS_MOCK=1` for dry demos).

## Wire clients (`mcporter.json`)

**Current fleet URL:** [`config/mcporter.json`](../../config/mcporter.json) uses **`http://192.168.11.160:8080/panos/mcp`** for `paloalto` (via **mcp-aggregator**). **GitLab** (`gitlab.ibhacked.us`) holds **source and images**, not this runtime URL.

On **mcp-aggregator**, forward **`/panos/mcp`** → `http://paloalto-mcp.<namespace>.svc.cluster.local:8765` (preserve MCP subpaths — see `deploy/k8s/mcp-aggregator/README.md`).

## Apply

```bash
kubectl apply -f deploy/k8s/paloalto-mcp/
```
