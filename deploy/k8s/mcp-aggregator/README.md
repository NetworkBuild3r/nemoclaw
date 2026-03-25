# MCP aggregator wiring (Kubernetes + OpenClaw)

## PAN-OS + ServiceNow paths (this fleet)

- **PAN-OS MCP (clients):** `http://<aggregator>:8080/panos/mcp` — see [`config/mcporter.json`](../../config/mcporter.json). **`gitlab.ibhacked.us`** is **not** the MCP endpoint; it hosts **Git / registry** for the `paloalto-mcp` image and source.
- **ServiceNow MCP:** `http://<aggregator>:8080/snow/mcp`

Your **OpenClaw `mcporter.json`** uses the **lab aggregator** (`192.168.11.160:8080`) with path prefixes for kubernetes, argocd, grafana, gitlab, **panos**, **snow**, etc. The backends in this repo use **SSE** at **`/mcp/sse`** on each pod (see `mcp-servers/paloalto/main.py`, `mcp-servers/servicenow/main.py`).

## Cluster context

- **ThinkPad / API server** (example): `192.168.11.129` — where `kubectl` talks (control plane).
- **MCP aggregator** — often a **NodePort / Ingress** on a node (e.g. `192.168.11.160:8080`). The aggregator must **proxy** each public path to the correct **internal Service** and preserve the MCP sub-paths (`/mcp/sse`, `/mcp/messages/`).

## Fix `404` on `/panos/mcp`

The client URL in `config/mcporter.json` is:

`http://<aggregator>:8080/panos/mcp`

Your **aggregator config** must forward to the **full SSE base** on the palo pod, for example:

| Backend | Internal URL |
|---------|----------------|
| Palo Alto MCP | `http://paloalto-mcp.mcp-paloalto.svc.cluster.local:8765/mcp/sse` |
| ServiceNow MCP | `http://servicenow-mcp.mcp-servicenow.svc.cluster.local:8766/mcp/sse` |
| Kubernetes MCP | *(depends on your aggregator image — often a single upstream URL)* |

If your proxy only appends path segments, you may need **`/paloalto` → strip** and **`proxy_pass`** to `http://paloalto-mcp.mcp-paloalto:8765` with **`/mcp/`** path rewrite. Test with:

```bash
curl -sS "http://<aggregator>:8080/panos/mcp" -H "Accept: text/event-stream" --max-time 2 || true
```

(Expect not necessarily 200 on bare GET; **no 404** once the route exists.)

## ServiceNow route

1. Build & push image from `mcp-servers/servicenow/` (same pattern as paloalto-mcp).
2. `kubectl apply -k deploy/k8s/servicenow-mcp/`
3. Register **`/snow/mcp`** → `servicenow-mcp:8766` (with same `/mcp/sse` rules as Palo).

## Kubernetes MCP

The **kubernetes** MCP server usually runs **inside** the cluster with a **ServiceAccount** and talks to `https://kubernetes.default.svc`. It is **not** the same as SSH to `192.168.11.129` — that host is for **admin / kubectl**. Ensure your aggregator’s **kubernetes** upstream is whatever your mcporter/k8s-mcp chart documents (often one HTTP MCP URL).

## NemoClaw sandbox egress

Allow the aggregator host:port in OpenShell policy, e.g. `config/policies/mcp_aggregator.preset.yaml` (`192.168.11.160:8080`). Add **ServiceNow instance** HTTPS if agents call Snow **directly** (not via MCP).

## Smoke (from ROC / gateway host)

```bash
cd /home/bnelson/nemoclaw && ./scripts/validate-mcp-endpoints.sh
```

Then use **OpenClaw** / `mcp-call` to list tools:

- `paloalto` → `panos_show_system_info`
- `servicenow` → `snow_create_incident` (with `SNOW_MOCK=1` returns mock payload)
