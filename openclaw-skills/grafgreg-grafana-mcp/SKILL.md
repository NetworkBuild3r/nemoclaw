---
name: grafgreg-grafana-mcp
description: GrafGreg’s Grafana MCP workflow — dashboards, PromQL, alerts, annotations — plus Archivist pipeline namespace. Use for grafgreg agent sessions.
metadata: {"openclaw":{"always":true}}
---

# Goal

Deliver **Grafana and metrics** answers through the **`grafana`** MCP server: bounded time ranges, interpretation over raw dumps, and **Archivist** notes for correlations with incidents or deploys.

## When to Use

- Finding dashboards, querying Prometheus, reviewing alerts or annotations.
- Explaining trends, spikes, or anomalies with evidence.

## Instructions

1. **MCP server:** ALWAYS call via `exec` using `mcp-call`. The third arg MUST be a JSON object in single quotes. NEVER pass bare words.
   - CORRECT: `mcp-call grafana search_dashboards '{"query":""}'`
   - CORRECT: `mcp-call grafana list_datasources '{}'`
   - CORRECT: `mcp-call grafana --list`
   - WRONG: `mcp-call grafana search_dashboards` (missing JSON arg — will error)
   - WRONG: `curl http://...` (wrong protocol)
2. **Typical tools:** `search_dashboards`, `get_dashboard_by_uid`, `list_datasources`, `query_prometheus`, `list_alert_rules`, `get_alert_instances`, `get_annotation`, `create_annotation`, `list_folders` — narrow the time window and query before scaling up scope.
3. **Interpretation:** Summarize in plain English first; support with numbers. Challenge weak causal claims; isolate variables (one change at a time).
4. **Time context:** Always state **time range** when quoting metrics.
5. **Lane:** Grafana/metrics only. Escalate GitLab, Argo CD, or kubectl to **Chief**.
6. **Archivist:** Store observations with `agent_id: "grafgreg"`, `namespace: "pipeline"` — dashboard, metric names, range, values, anomalies. Cross-search **pipeline** and **deployer** namespaces for deploy/incident correlation when useful.

## Scripts & References

- Persona: `{baseDir}/../../../AGENTS.md`
- MCP map: repository root `openclaw-skills/nemoclaw-mcp-fleet/`
- Archivist: repository root `openclaw-skills/archivist-mcp/`

## Security

- Metrics and alert labels can expose service names, customer traffic patterns, or PII-adjacent labels. Minimize quoting labels beyond what’s needed. Be cautious with `create_annotation` on widely visible dashboards.
