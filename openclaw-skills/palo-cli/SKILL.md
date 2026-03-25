---
name: palo-cli
description: Operate Palo Alto PAN-OS firewalls via the panos MCP server — system info, security rules, config reads, zones, interfaces, address/service objects. Covers the available MCP tools, common operational patterns, and Archivist audit logging. Use for firewall reads, troubleshooting, rule inspection, or feeding data into BPA reports.
metadata: {"openclaw":{"always":true}}
---

# Goal

Give **palo-expert** (and any agent delegated PAN-OS work) a precise reference for operating the **panos** MCP server: which tools exist today, how to call them, how to interpret results, and how to navigate the available configuration areas.

## When to Use

- Running any `paloalto` MCP tool (`panos_show_system_info`, `panos_list_security_rules`, `panos_config_get`).
- Building XPath queries to read zones, address objects, service objects, NAT rules, interfaces, or any other PAN-OS config node.
- Troubleshooting MCP call failures, mock-mode behavior, or unexpected XML API responses.
- Feeding raw config data into a BPA report (see `openclaw-skills/palo-best-practices-reporting/`).
- Planning which operational data to pull before an audit or change review.

## Instructions

### 1. Discover available tools

```bash
mcp-call panos --list
```

The **panos** MCP server provides 14+ read-only tools for firewall operations:

| Tool | Purpose |
|------|---------|
| `get_system_info` | Hostname, model, PAN-OS version, serial, uptime |
| `get_security_rules` | Security rulebase with profiles, logging, actions |
| `get_zones` | Zone list, protection profiles, interfaces |
| `get_interfaces` | Physical/logical interface config |
| `get_address_objects` | Address objects, names, values, usage |
| `get_service_objects` | Service objects, ports, protocols, usage |
| `get_nat_rules` | NAT policy rules |
| `get_security_profiles` | Antivirus, anti-spyware, vulnerability, URL filtering profiles |
| `get_virtual_routers` | Virtual router config and routing table |
| `get_management_config` | Management interface, admin users, services |
| ... | (use --list for full tool catalog) |

### 2. Pull system info

```bash
mcp-call panos get_system_info '{}'
```

Returns hostname, model, software version, uptime, serial, and license status. Use this first in every audit to identify the device and confirm connectivity. The live firewall is at **192.168.11.16**, model **PA-850**, running **PAN-OS 10.2.3**.

### 3. Read security rules

```bash
mcp-call panos get_security_rules '{}'
```

Returns the full security rulebase with rule names, source/destination zones, addresses, services, actions, and attached security profiles.

### 4. Query other config areas

Use the dedicated MCP tools for common operations:

```bash
# Zones and zone protection
mcp-call panos get_zones '{}'

# Network interfaces
mcp-call panos get_interfaces '{}'

# Address objects
mcp-call panos get_address_objects '{}'

# Service objects
mcp-call panos get_service_objects '{}'

# NAT rules
mcp-call panos get_nat_rules '{}'

# Security profiles
mcp-call panos get_security_profiles '{}'

# Virtual routers
mcp-call panos get_virtual_routers '{}'

# Management config
mcp-call panos get_management_config '{}'
```

All tools return structured JSON responses from the PAN-OS XML API.

### 5. Interpret responses

All tools return JSON with the following structure:

```json
{
  "status": "success",
  "data": { ... }
}
```

- **`status: "success"`** — requested data is in the `data` field.
- **`status: "error"`** — check `message` field for the error (auth failure, bad request, etc.).
- The MCP server is connected to the **live PA-850 at 192.168.11.16**, running **PAN-OS 10.2.3**. All responses reflect real configuration.

### 6. Audit logging

After every meaningful MCP call, store a summary in Archivist:

```bash
mcp-call archivist archivist_store '{"agent_id":"palo-expert","namespace":"firewall-ops","text":"Read zones via get_zones. Found 3 zones: trust, untrust, dmz. Zone protection: untrust has zp-external, trust has none (gap).","tags":["audit","panos","zones"]}'
```

- `agent_id`: always `palo-expert`.
- `namespace`: always `firewall-ops`.
- Store **interpretation**, not raw JSON blobs.

### 7. Live firewall details

| Property | Value |
|----------|-------|
| **Host** | 192.168.11.16 |
| **Model** | PA-850 |
| **PAN-OS** | 10.2.3 |
| **MCP server** | panos (in mcp-panos namespace) |
| **Aggregator route** | /panos/mcp |

The MCP server is deployed in Kubernetes, pod `mcp-panos`, connected to the live firewall via API key authentication.

### 8. Feeding BPA reports

For a best-practices assessment, pull data in this order:

1. `get_system_info` — device identity, version, licenses.
2. `get_security_rules` — full security rulebase.
3. `get_zones` — zone config and protection profiles.
4. `get_security_profiles` — antivirus, anti-spyware, vulnerability, URL filtering.
5. `get_management_config` — admin users, services, password policies.
6. `get_interfaces` — interface config and security.
7. `get_address_objects` + `get_service_objects` — object usage and naming.
8. `get_nat_rules` — NAT policy.

Then hand off to the `palo-best-practices-reporting` skill for analysis and report generation.

## Scripts & References

- `{baseDir}/references/REFERENCE.md` — operational patterns, response parsing, and common troubleshooting.
- `openclaw-skills/palo-best-practices-reporting/` — BPA audit and reporting skill.
- `agents/palo-expert/AGENTS.md` — agent role, safety rules, example commands.
- `agents/palo-expert/TOOLS.md` — Archivist RBAC for palo-expert.
- MCP server deployed in Kubernetes: `mcp-panos` namespace, pod `mcp-panos`, connected to PA-850 at 192.168.11.16.

## Security

- All MCP tools are **read-only**. This skill never modifies firewall configuration.
- Never store firewall credentials, API keys, or management IPs in Archivist or skill text. Reference Vault paths or env vars only.
- The MCP server authenticates via API key stored in Kubernetes secrets.
- Archivist writes use `agent_id: palo-expert`, `namespace: firewall-ops`. Do not write to other agents' namespaces.
