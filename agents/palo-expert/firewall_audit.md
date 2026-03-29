[FIREWALL PUBLIC ACCESS AUDIT]

## Inbound Public Access Rules

1. **Internet** (HIGH RISK)
   - Source: any from Untrust
   - Destination: any
   - Zones: Untrust → Trust/Wifi
   - Service: any
   - Application: any
   - Action: allow
   - Profiles: None
   - Risk: Broad any/any rule exposing the network to the internet

2. **GCP** (HIGH RISK)
   - Source: public-access group
   - Destination: internal hosts (beefy-cloud, dell-plex, ROG, Surface, etc.)
   - Zones: Untrust ↔ Trust/Untrust
   - Service: any
   - Application: any
   - Action: allow
   - Profiles: None
   - Risk: Public hosts can reach internal servers/workstations without restrictions

3. **cloudflare** (MEDIUM RISK)
   - Source: cloudflare IP space
   - Destination: internal hosts (beefy-cloud, dell-plex, Surface, etc.)
   - Zones: Untrust ↔ Trust/Untrust
   - Service: any
   - Application: any
   - Action: allow
   - Profiles: None
   - Risk: Broad access from Cloudflare to internal assets

4. **gitlabs** (HIGH RISK)
   - Source: any
   - Destination: xmission-253
   - Zones: Untrust → Trust
   - Service: 22-tcp
   - Application: any
   - Action: allow
   - Profiles: None
   - Risk: Unrestricted public SSH access to internal host

5. **plex** (MEDIUM RISK)
   - Source: any
   - Destination: xmission-250, xmission-253, xmission-254
   - Zones: Untrust → Trust
   - Service: 32400-tcp
   - Application: any
   - Action: allow
   - Profiles: None
   - Risk: Internal Plex servers exposed to public with no source restrictions

6. **Rust** (DISABLED)
   - Source: any
   - Destination: beefy-cloud, xmission-250
   - Zones: Untrust → Trust
   - Service: 8000-tcp, 28015-udp, 28016-tcp
   - Application: any
   - Action: allow
   - Profiles: None
   - Risk: Disabled but shows previously broad ports exposed

7. **AHEAD ollama** (MEDIUM RISK)
   - Source: 69.161.205.2
   - Destination: ROG, xmission-255
   - Zones: Untrust → Trust
   - Service: any
   - Application: any
   - Action: allow
   - Profiles: None
   - Risk: Single source IP but still broadly accessible internal hosts

## NAT Exposure

- dell-plex (xmission-253) exposed to Untrust
- xmission-255 exposed to public via GCP-Server nat 
- k3-ip_vip (xmission-254) exposed to public

## Critical Findings

1. Multiple any/any rules from Untrust zone to internal hosts, with no security profiles applied.
2. Unrestricted public access to SSH (22-tcp) and Plex (32400-tcp) servers.
3. Broad NAT rules exposing internal hosts to public internet.

## Recommendations

**Immediate:**
- Apply security profile groups to all inbound Untrust → Trust rules
- Remove any/any service/application rules and require specific application definitions
- Restrict source IPs and address groups on rules, don't use "any"

**Short-term:** 
- Disable public SSH access or restrict to specific source IPs/groups
- Review and narrow NAT rules to only what's strictly necessary

**Long-term:**
- Implement a strict default-deny policy at the bottom of the rulebase
- Use application-based policies instead of just port/protocol matching
- Enable logging on all rules to improve visibility
- Investigate segmentation between internal zones (Trust, Wifi, etc.)