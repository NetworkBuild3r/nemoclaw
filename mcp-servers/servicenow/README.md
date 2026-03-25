# ServiceNow MCP (incident + change)

Small **SSE** MCP server compatible with the same aggregator pattern as **`mcp-servers/paloalto`**.

## Tools

| Tool | Action |
|------|--------|
| `snow_create_incident` | `POST /api/now/table/incident` |
| `snow_create_change` | `POST /api/now/table/change_request` |

## Environment

| Variable | Purpose |
|----------|---------|
| `SNOW_INSTANCE` | Base URL, e.g. `https://YOURcompany.service-now.com` |
| `SNOW_USER` | Basic auth user |
| `SNOW_PASSWORD` | Basic auth password |
| `SNOW_MOCK` | `1` — return mock JSON without calling ServiceNow |
| `MCP_PORT` | Default `8766` |

## Local run

```bash
cd mcp-servers/servicenow
pip install -r requirements.txt
export SNOW_MOCK=1
python main.py
# health: http://127.0.0.1:8766/health
```

## Kubernetes

```bash
docker build -t YOUR_REGISTRY/servicenow-mcp:latest .
docker push YOUR_REGISTRY/servicenow-mcp:latest
kubectl apply -k deploy/k8s/servicenow-mcp/
```

Patch `deployment.yaml` image + `Secret` for live credentials (`SNOW_MOCK=0`).
