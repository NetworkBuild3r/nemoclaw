# TOOLS.md — Palo Expert

| **agent_id** | `palo-expert` |
| **Write namespace** | `firewall-ops` |
| **Read** | Search `mcp-engineering`, `skills-research`, `tasks` for context |
| **paloalto MCP** | `mcp-call paloalto <tool> '<json>'` |
| **archivist** | Store audit results after analysis |

Aggregator base: `MCP_AGGREGATOR` (see `config/mcporter.json`).

## How to Call MCP Tools

**You have access to the `exec` tool.** Use it to run `mcp-call` commands:

```
exec: mcp-call paloalto get_security_rules '{}'
exec: mcp-call paloalto get_nat_rules '{}'
exec: mcp-call archivist archivist_store '{"agent_id":"palo-expert","namespace":"firewall-ops","text":"...","tags":["audit"]}'
```

These are **live calls to the actual firewall** — not samples or hypotheticals. Run the commands, read the JSON responses, analyze them, and report findings.

**List available tools:**
```
exec: mcp-call paloalto --list
exec: mcp-call archivist --list
```

## Common Audit Patterns

### Public Access Security Review

```bash
# 1. Get all security rules
mcp-call paloalto get_security_rules '{}'

# 2. Get NAT policies (what's exposed via public IPs)
mcp-call paloalto get_nat_rules '{}'

# 3. Understand address objects and groups
mcp-call paloalto get_address_objects '{}'
mcp-call paloalto get_address_groups '{}'

# 4. Check security profiles (should be applied to inbound rules)
mcp-call paloalto get_all_security_profiles '{}'
mcp-call paloalto get_security_profile_groups '{}'

# 5. Zone configuration
mcp-call paloalto get_zones '{}'

# Analysis checklist:
# - Rules with source="any" from Untrust zone
# - Any/any patterns (service=any, application=any)
# - Public SSH/RDP (port 22, 3389) without source restrictions
# - Missing security profiles on inbound rules
# - NAT rules exposing internal hosts to public IPs
# - Overly broad destination lists

# 6. Store findings
mcp-call archivist archivist_store '{"agent_id":"palo-expert","namespace":"firewall-ops","text":"Audit findings: [high-risk rules], [NAT exposure], [recommendations]","tags":["audit","public-access"]}'
```

### Rule-Specific Analysis

```bash
# Get specific rule details
mcp-call paloalto get_security_rules '{"rulename":"<name>"}'

# Check what services are defined
mcp-call paloalto get_service_objects '{}'
mcp-call paloalto get_service_groups '{}'

# Review threat prevention profiles
mcp-call paloalto get_security_profiles '{"profile_type":"vulnerability"}'
mcp-call paloalto get_security_profiles '{"profile_type":"anti-spyware"}'
```

### System Health & Compliance

```bash
# System info
mcp-call paloalto get_system_info '{}'

# Content versions (signatures up to date?)
mcp-call paloalto get_content_versions '{}'

# Recent config changes
mcp-call paloalto get_config_audit '{}'

# Interface status
mcp-call paloalto get_interfaces '{}'
```

## Analysis Framework

When reviewing security rules, look for:

1. **HIGH RISK:**
   - Source: `any` from Untrust → Trust/DMZ
   - Service/Application: `any/any`
   - Public SSH/RDP without IP restrictions
   - Missing security profiles on inbound rules
   - NAT exposing internal hosts to broad public access

2. **MEDIUM RISK:**
   - Specific public IPs but overly broad services
   - Application = `any` (no app-id)
   - Multiple unrelated hosts in single destination
   - Disabled logging

3. **BEST PRACTICES:**
   - Default deny at bottom of rulebase
   - Security profile groups on all allow rules from Untrust
   - Application-based policies (not just ports)
   - Zone protection profiles
   - Explicit source IP restrictions for management access

## Output Format

Structure audit findings as:

```
=== INBOUND PUBLIC ACCESS RULES ===

1. **[Rule Name]** (RISK LEVEL)
   - Source: [specific IPs or "ANY"]
   - Destination: [hosts/IPs]
   - Zones: [from] → [to]
   - Service: [ports/protocols]
   - Application: [app-id or "ANY"]
   - Action: [allow/deny]
   - Profiles: [security profile group or "None"]
   - Risk: [explanation]

=== NAT EXPOSURE ===
[Public IP] → [Internal IP/Host] [context]

=== CRITICAL FINDINGS ===
1. [Finding with evidence]
2. ...

=== RECOMMENDATIONS ===
**Immediate:** [actions]
**Short-term:** [actions]
**Long-term:** [actions]
```

Store this in Archivist `firewall-ops` after completing the analysis.
