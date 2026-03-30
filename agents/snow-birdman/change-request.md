[ServiceNow Change Request Draft]

Goal: Remove two unused/risky firewall rules from brian-firewall.nemoclaw.com

Changes requested:
1. Delete disabled "Rust" rule - currently off, exposes Rust app ports (8000, 28015, 28016) if re-enabled
2. Delete AHEAD ollama rule - allows specific source IP (69.161.205.2) to reach ROG and xmission-255 without service restrictions

Affected systems:
- Firewall: brian-firewall.nemoclaw.com
- Zones: internal, external
- Dependent services: Rust app (8000, 28015, 28016), ROG, xmission-255

Risk assessment: Standard/normal. These are unused/overly-permissive rules that should be cleaned up for security hygiene.

Implementation plan:
1. Delete the two rules via PAN-OS web UI
2. Commit the changes

Rollback plan:
Restore the rules from the firewall configuration backup if needed.

Schedule: Midday today (2026-03-30, ~12:00 MDT)