---
name: palo-best-practices-reporting
description: Generate PAN-OS best-practices assessment reports from live firewall config via panos MCP, analyze against CIS/PAN hardening benchmarks, write Markdown reports, and log metadata to Archivist. Use for firewall posture audits, compliance reviews, or periodic BPA checks.
metadata: {"openclaw":{"always":true}}
---

# Goal

Pull live PAN-OS configuration via the **panos** MCP server, evaluate it against CIS and Palo Alto hardening benchmarks, produce a scored Markdown report, and persist audit metadata in Archivist — all without storing full report text in memory.

## When to Use

- Brian (or Chief) requests a best-practices assessment or firewall posture review.
- Periodic compliance check against CIS Palo Alto Firewall Benchmark or PAN hardening guidelines.
- Post-change audit after a firewall policy or configuration update.
- Generating documentation for an AHEAD demo, customer deliverable, or internal review.

## Instructions

1. **Gather config** — call each panos MCP tool to collect the live state:
   - `get_system_info` — hostname, model, PAN-OS version, licenses, uptime.
   - `get_security_rules` — full rulebase with profiles, logging, actions.
   - `get_zones` — zone list, protection profiles, interfaces.
   - `get_interfaces` — physical/logical interface config.
   - `get_address_objects` — address objects, names, values, usage.
   - `get_service_objects` — service objects, ports, protocols, usage.
   - `get_security_profiles` — antivirus, anti-spyware, vulnerability, URL filtering.
   - `get_management_config` — admin users, services, password policies.
   - `get_nat_rules` — NAT policy rules.

2. **Analyze findings** — evaluate the gathered config against the BPA checklist in `{baseDir}/references/REFERENCE.md` and the full reference in `agents/chief/bpa-reference.md`. Prioritize Critical and High checks. For each check determine **Pass / Fail / N/A** and note the gap and recommended action when it fails.

   **MANDATORY EOL/Support Checks (Critical severity):**
   - **Hardware EOL:** Check if the model (e.g. PA-850) is end-of-life or end-of-support. Reference [Palo Alto End-of-Life announcements](https://www.paloaltonetworks.com/services/support/end-of-life-announcements/hardware). Flag if device is EOL or approaching end-of-support.
   - **Software EOL:** Check if PAN-OS version (e.g. 10.2.3) is end-of-life or no longer receiving security updates. Reference [PAN-OS Software Release Notes](https://docs.paloaltonetworks.com/pan-os) and the [PAN-OS Software Updates calendar](https://www.paloaltonetworks.com/services/support/end-of-life-announcements/end-of-life-summary). Flag if software is EOL or out of maintenance window.
   - **Support Contract Status:** Verify the serial number has an active support contract (if accessible via API or manual check). Without support, the device cannot download updates.
   - **Content Updates:** Check `av-version`, `threat-version`, `wildfire-version`, `url-filtering-version` from `get_system_info` or `get_content_versions`. **Zero or very old versions are Critical gaps** — the firewall cannot detect current threats without updated signatures.
   
   **Example failures:**
   - PA-850 on PAN-OS 10.2.x where 10.2 is EOL → **Critical: Software EOL**
   - `av-version: 0`, `threat-version: 0` → **Critical: No antivirus or threat signatures installed**
   - Hardware nearing end-of-support (e.g. PA-800 series approaching EOL window) → **High: Plan hardware refresh**

3. **Score posture** — assign an overall grade:
   - **Compliant** — no Critical or High failures.
   - **Needs Improvement** — one or more High failures, no Critical.
   - **Critical Gaps** — one or more Critical failures.

4. **Write the report** — use the template in `{baseDir}/references/REFERENCE.md` (section "Report Template"). Save to:
   ```
   reports/palo-best-practices-YYYYMMDD.md
   ```
   Include an executive summary, per-domain tables, a prioritized risk summary, and an appendix with raw tool output snippets for audit trail.

5. **Log to Archivist** — store a **summary + file path** (never the full report):
   ```
   mcp-call archivist archivist_store '{"agent_id":"palo-expert","namespace":"firewall-ops","text":"BPA report: reports/palo-best-practices-YYYYMMDD.md. Device: <hostname>. Posture: <grade>. Top risks: <1>, <2>, <3>.","tags":["audit","best-practices","report-metadata"]}'
   ```
   Then log trajectory and end session — see `{baseDir}/references/REFERENCE.md` for the full Archivist pattern.

6. **Cross-reference OPA rules** — when a finding maps to an implemented Rego rule (SEC-PA-xxx, TP-PA-xxx, etc.), note the rule ID in the report for traceability. The rule index is in `{baseDir}/references/REFERENCE.md`.

## Scripts & References

- `{baseDir}/references/REFERENCE.md` — report template, BPA checklist index, MCP tool table, Archivist patterns, OPA rule cross-reference.
- `agents/chief/bpa-reference.md` — full hardening checklist with every check, severity, and CIS reference.
- `agents/palo-expert/` — palo-expert agent workspace (AGENTS.md, TOOLS.md).

## Security

- Never store API keys, firewall credentials, or management IPs in the report or in Archivist. Use placeholders if examples reference live infrastructure.
- Do not store full report text in Archivist — only summary, file path, and top-risk tags. Reports live on disk under `reports/`.
- Archivist writes use `agent_id: palo-expert`, `namespace: firewall-ops`. Do not write to other agents' namespaces.
- All panos MCP calls are read-only. This skill never modifies firewall configuration.
