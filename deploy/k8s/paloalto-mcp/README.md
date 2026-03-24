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

## Wire the aggregator

On the host that runs **mcp-aggregator** (this repo uses `http://192.168.11.160:8080/...`), add a route that forwards:

- Path prefix: `/paloalto` (or your convention)
- Backend: `http://paloalto-mcp.<namespace>.svc.cluster.local:8765`

So clients use: `http://<aggregator>:8080/paloalto/mcp` — match [`config/mcporter.json`](../../config/mcporter.json) `paloalto.url`.

## Apply

```bash
kubectl apply -f deploy/k8s/paloalto-mcp/
```
