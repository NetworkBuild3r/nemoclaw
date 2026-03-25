# PAN-OS BPA Report — Reference Material

Detailed best-practice checklists, report template, and Archivist patterns for the `palo-best-practices-reporting` skill.

---

## Authoritative Sources

| Source | Version / Date | URL |
|--------|---------------|-----|
| Palo Alto Networks Configuration Hardening Guidelines | Current | https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000ClIaCAK |
| CIS Palo Alto Firewall 11 Benchmark | v1.1.0, 2023 | https://www.cisecurity.org/benchmark/palo_alto_networks |
| CIS Palo Alto Firewall 10 Benchmark | v1.3.0 | https://www.cisecurity.org/benchmark/palo_alto_networks |
| Palo Alto Administrative Access Best Practices | PAN-OS 10.1+ | https://docs.paloaltonetworks.com/best-practices/10-1/administrative-access-best-practices |
| Palo Alto Internet Gateway Best Practices | Current | https://docs.paloaltonetworks.com/best-practices/internet-gateway-best-practices |
| Palo Alto Security Policy Best Practices | Current | https://docs.paloaltonetworks.com/best-practices/security-policy-best-practices |
| Palo Alto Zone Protection Recommendations | Current | https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000ClVkCAK |
| NIST NCP — CIS Palo Alto Firewall 10 Benchmark | Checklist 1195 | https://ncp.nist.gov/checklist/1195 |

---

## Report Template

Every BPA report written to `reports/palo-best-practices-YYYYMMDD.md` should follow this structure:

```markdown
# PAN-OS Best-Practices Assessment — YYYY-MM-DD

**Device:** <hostname> (<model>, PAN-OS <version>)
**Assessed by:** palo-expert (OpenClaw)
**Overall posture:** <Compliant | Needs Improvement | Critical Gaps>

## Executive Summary
<2-3 sentences: top risks, posture grade, recommended priority actions>

## Management Plane
| Check | Best Practice | Severity | CIS Ref | Status | Gap | Action |
|-------|--------------|----------|---------|--------|-----|--------|
| ... | ... | ... | ... | Pass/Fail/N/A | ... | ... |

## Network & Zone Security
(same table format)

## High Availability
(same table format)

## Control Plane — Security Policy
(same table format)

## Threat Prevention
(same table format)

## Data Plane — Security Profiles & Logging
(same table format)

## Object Management
(same table format)

## SSL/TLS Decryption
(same table format)

## Operational Checks
(same table format)

## Risk Summary
| Priority | Finding | Severity | Recommended Action |
|----------|---------|----------|--------------------|
| 1 | ... | Critical | ... |

## Appendix: Tool Outputs
<Raw MCP output snippets for audit trail>
```

---

## BPA Checklist by Domain

The full checklist lives in `agents/chief/bpa-reference.md`. Below is a condensed index of domains and high-value checks to prioritize during report generation.

### Management Plane (Critical / High)

- Default admin password changed (Critical)
- Password complexity enabled — length >= 12, upper/lower/numeric/special (Critical, CIS 1.3.x)
- Permitted IPs on mgmt interface + all mgmt profiles (Critical, CIS 1.2.1-1.2.2)
- HTTP/Telnet disabled on mgmt and all profiles (Critical, CIS 1.2.3-1.2.4)
- Syslog logging configured (Critical, CIS 1.1.1.1)
- Idle timeout <= 10 min (High, CIS 1.4.1)
- Failed-attempts lockout (High, CIS 1.4.2)
- External auth (RADIUS/TACACS+/LDAP) (High)
- SNMPv3 (High, CIS 1.5.1)

### Network & Zone Security (Critical / High)

- Zone protection on untrusted zones (Critical, CIS 6.16)
- Anti-spoofing enabled (Critical)
- Flood protection thresholds (High)
- Reconnaissance protection (High)
- User-ID on internal zones only (Critical, CIS 2.3)

### High Availability

- HA peer configured and synchronized (High, CIS 3.1)
- Link/path monitoring enabled (High, CIS 3.2)
- Matched HW/SW versions (High)

### Security Policy (Critical / High)

- Security profiles on all allow rules (Critical)
- No overly permissive any/any rules (Critical)
- Explicit deny-all at bottom (High)
- Session-end logging on all rules (High)
- App-ID policies for cross-zone traffic (Critical, CIS 7.1)

### Threat Prevention (Critical / High)

- AV updates hourly (Critical, CIS 4.1)
- App & Threat updates daily (Critical, CIS 4.2)
- WildFire profile on all policies (Critical, CIS 5.2)
- WildFire real-time updates (Critical, CIS 5.6)
- Anti-spyware on Internet-bound policies (Critical, CIS 6.5)
- Vuln protection on all allowing rules (Critical, CIS 6.7)

### Operational Checks

- HA sync status (Critical)
- Threat signature currency (High)
- WildFire connectivity (High)
- License status (High)
- Session table and CPU utilization (Medium-High)
- Certificate expiration within 30 days (High)

---

## MCP Tools — PAN-OS Server

| Tool | Returns | Use for |
|------|---------|---------|
| `get_system_info` | Hostname, model, PAN-OS version, licenses, uptime | Management plane, operational checks, version compliance |
| `get_security_rules` | Full rulebase (source/dest/app/service/action/profiles/logging) | Policy analysis, profile attachment, any/any detection |
| `get_zones` | Zone list with protection profiles, interfaces | Zone security, protection profile coverage |
| `get_address_objects` | Address objects with names, values, usage | Object hygiene, unused object detection |
| `get_service_objects` | Service objects with ports, protocols, usage | Object hygiene, unused service detection |

---

## Archivist Patterns

**Store report metadata (not full report text):**

```
mcp-call archivist archivist_store '{"agent_id":"palo-expert","namespace":"firewall-ops","text":"BPA report generated: reports/palo-best-practices-YYYYMMDD.md. Device: <hostname>. Posture: <grade>. Top risks: <1>, <2>, <3>.","tags":["audit","best-practices","report-metadata"]}'
```

**Log trajectory for the audit session:**

```
mcp-call archivist archivist_log_trajectory '{"agent_id":"palo-expert","namespace":"firewall-ops","action":"bpa-report","detail":"Pulled config via panos MCP, analyzed against CIS/PAN hardening, wrote report to reports/palo-best-practices-YYYYMMDD.md","tags":["audit","trajectory"]}'
```

**End session after report delivery:**

```
mcp-call archivist archivist_session_end '{"agent_id":"palo-expert","namespace":"firewall-ops","summary":"BPA audit complete. Report: reports/palo-best-practices-YYYYMMDD.md. Posture: <grade>.","tags":["audit","session-end"]}'
```

---

## Implemented OPA Rules (for cross-reference)

The OPA Rego policy set covers these rule IDs. When a BPA check maps to an implemented rule, note it in the report for traceability.

- **SEC-PA-001–010**: Management plane (idle timeout, password, banner, syslog, mgmt IP, NTP, SNMPv3, HTTP/Telnet, lockout, external auth)
- **SEC-PA-020–025**: Security policy (profile groups, logging, decryption, deny-all, file blocking, permissive rules)
- **TP-PA-001–007**: Threat prevention (WildFire, AV, anti-spyware, vuln protection, URL filtering, DNS security, WF real-time)
- **ZP-PA-001–003**: Zone protection (profile applied, SYN flood, packet-based attacks)
- **HA-PA-001**: HA configured
- **AVL-PA-001–009**: Operational (licenses, signature currency, device cert, GlobalProtect)
- **PERF-PA-001**: PAN-OS version on supported train
