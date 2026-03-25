# Palo Alto Networks PAN-OS — BPA Best Practice Reference

Authoritative sources for Palo Alto Networks firewall hardening, organized by functional domain. Use this reference when writing or reviewing OPA Rego policies under opa-policies/bpa/paloalto/.

> Note: Palo Alto firewalls are NGFW appliances — they don't expose traditional CLI-style running-config like IOS/EOS/Junos. Config is XML-based (exported via show config running or API). Rego policies for PAN-OS will primarily parse XML or structured JSON exports from Panorama/firewalls.

---

## Sources

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

## Management Plane

### Administrative Access & Password Security

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Default admin password changed | Change default admin/admin before connecting to network | Critical | — |
| Minimum password complexity enabled | Enable complexity enforcement in Device > Setup > Management | Critical | 1.3.1 |
| Minimum password length >= 12 | Set minimum length to at least 12 characters | Critical | 1.3.2 |
| Minimum uppercase letters >= 1 | Require at least 1 uppercase letter | High | 1.3.3 |
| Minimum lowercase letters >= 1 | Require at least 1 lowercase letter | High | 1.3.4 |
| Minimum numeric characters >= 1 | Require at least 1 numeric character | High | 1.3.5 |
| Minimum special characters >= 1 | Require at least 1 special character | High | 1.3.6 |
| Password change period <= 90 days | Enforce password rotation | Medium | 1.3.7 |
| New password differs by >= 3 chars | Prevent trivial password changes | Medium | 1.3.8 |
| Password reuse limit >= 24 | Prevent reuse of recent passwords | Medium | 1.3.9 |
| No per-user password profiles | Do not override global password policy with per-user profiles | Medium | 1.3.10 |
| Idle timeout <= 10 minutes | Timeout inactive admin sessions | High | 1.4.1 |
| Failed attempts lockout configured | Lock account after failed login attempts | High | 1.4.2 |

### Authentication & Authorization

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| External authentication configured | Use RADIUS, TACACS+, LDAP, or Kerberos for admin auth | High | — |
| Admin roles defined | Use role-based admin profiles to limit access | High | — |
| MFA enabled for admin access | Enable multi-factor authentication | High | — |
| Authentication profile with lockout | Configure Authentication Profile with failed attempts + lockout time | High | 1.4.2 |

### Management Interface Hardening

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Permitted IP addresses on mgmt interface | Restrict management access by source IP | Critical | 1.2.1 |
| Permitted IP addresses on all mgmt profiles | Restrict access on interface management profiles with SSH/HTTPS/SNMP | Critical | 1.2.2 |
| HTTP disabled on management interface | Disable HTTP on mgmt interface | Critical | 1.2.3 |
| Telnet disabled on management interface | Disable Telnet on mgmt interface | Critical | 1.2.3 |
| HTTP disabled on all management profiles | Disable HTTP on all interface management profiles | Critical | 1.2.4 |
| Telnet disabled on all management profiles | Disable Telnet on all interface management profiles | Critical | 1.2.4 |
| Valid HTTPS certificate for admin interface | Use trusted PKI certificate for web management | High | 1.2.5 |
| Management interface in dedicated VLAN | Isolate management traffic to dedicated VLAN | High | — |
| Unnecessary services disabled on interfaces | Do not enable ping/SSH/HTTPS on interfaces that don't need them | High | — |

### SNMP Hardening

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| SNMPv3 used for polling | Use SNMPv3 instead of v2c | High | 1.5.1 |
| SNMPv3 traps configured | Configure SNMPv3 trap destinations | Medium | 1.1.1.2 |
| SNMP community string not guessable | Use complex, unique community strings | High | — |
| SNMP on internal interfaces only | Enable SNMP only on internal/management interfaces | High | — |

### Logging & Monitoring

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Syslog logging configured | Forward logs to external syslog server | Critical | 1.1.1.1 |
| Login banner set | Display legal notice on admin login | Medium | 1.1.2 |
| Log on high DP load enabled | Enable logging when dataplane load is high | High | 1.1.3 |
| System and config log monitoring | Monitor logs for unauthorized changes | Medium | — |
| Log forwarding profile on all rules | Attach log forwarding profile to every security rule | High | — |

### NTP & Update Services

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Redundant NTP servers configured | Configure at least two NTP servers | Medium | 1.6.2 |
| Verify update server identity | Enable server identity verification for content updates | High | 1.6.1 |
| Valid VPN certificate | Ensure certificate securing remote access VPN is valid | High | 1.6.3 |

---

## Network & Zone Security

### Zone Protection Profiles

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Zone protection on untrusted zones | Apply zone protection profile to all untrusted/external zones | Critical | 6.16 |
| Flood protection configured | Configure SYN, UDP, ICMP, and other flood thresholds | High | 6.16 |
| Reconnaissance protection enabled | Enable port scan and host sweep detection on all zones | High | — |
| Packet-based attack protection | Drop unknown/malformed IP options, enable TCP mismatch detection | High | — |
| Anti-spoofing enabled | Enable "Spoofed IP addresses" check in zone protection profile | Critical | — |
| Zone protection on all zones (zero-trust) | Apply zone protection to internal zones as well | Medium | — |

### User-ID Security

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| User-ID on internal trusted zones only | Do not enable User-ID on untrusted/external interfaces | Critical | 2.3 |
| Include/Exclude networks configured | Restrict User-ID scope with network lists | High | 2.4 |
| User-ID Agent minimal permissions | Limit service account permissions | High | 2.5 |
| User-ID service account no interactive logon | Prevent interactive login for User-ID service account | High | 2.6 |
| User-ID service account no remote access | Disable remote access for User-ID service account | High | 2.7 |
| User-ID Agent traffic restricted from untrusted zones | Security policies block User-ID traffic crossing trust boundaries | High | 2.8 |
| IP-to-username mapping enabled | Map IP addresses to usernames for visibility | Medium | 2.1 |
| WMI probing disabled | Disable WMI-based User-ID probing | Medium | 2.2 |

---

## High Availability

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| HA peer configured and synchronized | Deploy fully-synchronized HA pair | High | 3.1 |
| Link monitoring and/or path monitoring | Enable HA health monitoring | High | 3.2 |
| Passive link state and preemptive configured | Configure appropriate failover behavior | Medium | 3.3 |
| Matched hardware and software versions | HA peers must run same PAN-OS version on same hardware model | High | — |

---

## Control Plane

### Security Zones & Segmentation

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Zone protection profiles configured | Apply zone protection to all zones | High | — |
| Trust boundaries clearly defined | Separate trust/untrust/DMZ zones | High | — |
| Intrazone default deny | Block intra-zone traffic unless explicitly allowed | Medium | — |
| Interzone default deny | Enforce explicit allow rules for inter-zone traffic | High | — |
| Zone names descriptive | Use meaningful names (not zone1, zone2) | Low | — |

### Security Policy

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Default deny at bottom of rulebase | Ensure implicit deny-all at end | High | — |
| All rules have descriptions | Document purpose of each rule | Medium | — |
| All rules have tags | Use tags for lifecycle/ownership tracking | Low | — |
| No "any" source in allow rules | Specify source zones/addresses | High | — |
| No "any" destination in allow rules | Specify destination zones/addresses | High | — |
| No "any" service in allow rules | Specify services/applications | High | — |
| Security profiles on all allow rules | Attach threat prevention, antivirus, anti-spyware, URL filtering | Critical | — |
| Session-end logging on all allow rules | Enable log-at-session-end for visibility | High | — |
| Hit count tracking enabled | Monitor rule usage for lifecycle management | Medium | — |

---

## Threat Prevention (Security Profiles)

### Content Updates

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Antivirus updates hourly | Schedule AV signature download + install hourly | Critical | 4.1 |
| App & Threat updates daily or shorter | Schedule App-ID + Threat updates at least daily | Critical | 4.2 |

### WildFire

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| WildFire upload limits maximized | Maximize file size upload limits for all file types | High | 5.1 |
| WildFire profile on all policies | Attach WildFire Analysis profile to every security policy | Critical | 5.2 |
| Decrypted content forwarded to WildFire | Enable forwarding of decrypted traffic for analysis | High | 5.3 |
| WildFire session info settings enabled | Enable all session information settings | Medium | 5.4 |
| WildFire malicious file alerts | Enable alerts for malicious file detections | High | 5.5 |
| WildFire updates real-time | Set WildFire signature updates to real-time | Critical | 5.6 |
| WildFire cloud region selected | Choose appropriate WildFire cloud region | Medium | 5.7 |

### Antivirus

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| AV profile reset-both on most decoders | Set action to reset-both for all decoders except imap/pop3 | High | 6.1 |
| AV profile on all relevant policies | Apply antivirus profile to all security policies allowing traffic | Critical | 6.2 |

### Anti-Spyware

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Anti-spyware blocks all severity levels | Configure blocking for all spyware severity levels/categories | High | 6.3 |
| DNS sinkholing configured | Enable DNS sinkholing on all anti-spyware profiles | High | 6.4 |
| Anti-spyware on Internet-bound policies | Apply anti-spyware profile to all Internet-facing security policies | Critical | 6.5 |

### Vulnerability Protection

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Vuln protection blocks critical + high | Block critical and high severity attacks; default for medium/low/info | High | 6.6 |
| Vuln protection on all allowing rules | Apply Vulnerability Protection profile to all rules allowing traffic | Critical | 6.7 |

### URL Filtering

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| PAN-DB URL Filtering used | Use PAN-DB (not BrightCloud) for URL categorization | High | 6.8 |
| URL categories block or override | Set action to block or override on high-risk URL categories | High | 6.9 |
| All URL access logged | Enable logging for all URL categories | Medium | 6.10 |

### File Blocking

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| File blocking profile configured | Block high-risk file types (PE, DLL, batch, etc.) | High | — |
| File blocking on Internet-bound rules | Apply file blocking to Internet-facing security policies | High | — |

---

## Data Plane

### Security Profiles

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Antivirus profile configured | Enable antivirus scanning | High | — |
| Anti-spyware profile configured | Enable anti-spyware detection | High | — |
| Vulnerability protection profile configured | Enable vulnerability protection | High | — |
| URL filtering profile configured | Enable URL category filtering | High | — |
| File blocking profile configured | Block risky file types (e.g., .exe, .dll) | Medium | — |
| Wildfire analysis enabled | Enable cloud-based advanced threat analysis | High | — |
| Security profile group applied to all allow rules | Attach profile group to all allow rules | Critical | — |

### Logging & Visibility

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Log forwarding configured | Forward logs to syslog/SIEM | High | — |
| Session-end logging on all allow rules | Ensure visibility into allowed traffic | High | — |
| Threat logs enabled | Log all threat events | High | — |
| URL filtering logs enabled | Log URL category hits | Medium | — |
| Data filtering logs enabled | Log data leak prevention events | Medium | — |
| Log storage sufficient | Ensure local/remote storage capacity | Medium | — |

---

## Object Management

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Address objects used instead of inline IPs | Define reusable address objects | Medium | — |
| Service objects used instead of inline ports | Define reusable service objects | Medium | — |
| Unused address objects removed | Clean up stale objects | Low | — |
| Unused service objects removed | Clean up stale objects | Low | — |
| Object names descriptive | Use meaningful names (not obj1, obj2) | Low | — |
| Object descriptions populated | Document purpose of each object | Low | — |

---

## Security Policy

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Application security policies (untrusted to trusted) | Use App-ID-based policies for cross-zone traffic | Critical | 7.1 |
| No overly permissive "any/any" rules | Avoid rules allowing any app/any service | Critical | — |
| Explicit deny-all at bottom of rulebase | Ensure last rule denies all unmatched traffic | High | — |
| Security profiles on all allow rules | Attach threat prevention profiles to every allow rule | Critical | — |
| Log at session end on all rules | Enable logging at session end | High | — |
| Unused rules removed | Remove or disable unused security rules | Medium | — |

---

## SSL/TLS Decryption

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| Decryption enabled for inspection | Configure SSL forward proxy decryption for outbound traffic | High | — |
| Trusted decryption certificate | Use trusted CA certificate for SSL decryption | High | 8.3 |
| Decryption profile configured | Apply decryption profile with TLS version and cipher restrictions | Medium | — |

---

## Operational Checks

| Check | Data Source | FAIL Condition | Severity |
|-------|------------|----------------|----------|
| HA peer sync status | show high-availability state | Peer not synchronized or not connected | Critical |
| Threat signature currency | show system info / content version | AV/App-Threat signatures older than threshold | High |
| WildFire connectivity | test wildfire registration | WildFire not registered or unreachable | High |
| License status | show system info | Expired subscriptions (Threat, URL, WildFire, GlobalProtect) | High |
| Session table utilization | show session info | Session count > 80% of maximum | Medium |
| Dataplane CPU utilization | show running resource-monitor | Sustained DP CPU > 80% | High |
| Management plane CPU | show system resources | Sustained MP CPU > 80% | Medium |
| Firmware version consistency | Device inventory | Different PAN-OS versions across HA pair or Panorama-managed fleet | High |
| Config out of sync with Panorama | Panorama managed devices | Device config diverged from Panorama template/device group | Medium |
| Certificate expiration | show sslmgr-store config-certificate-info | Certificates expiring within 30 days | High |

---

## Rule ID Scheme

Palo Alto-specific rules use the prefix pattern <CATEGORY>-PA-NNN:

- SEC-PA-001 through SEC-PA-050 — Security checks (management hardening, auth, etc.)
- TP-PA-001 through TP-PA-030 — Threat Prevention checks (AV, AS, VP, URL, WildFire)
- ZP-PA-001 through ZP-PA-010 — Zone Protection checks
- HA-PA-001 through HA-PA-005 — High Availability checks
- AVL-PA-001 through AVL-PA-015 — Availability / operational checks
- PERF-PA-001 through PERF-PA-010 — Performance checks

Common rules that include Palo Alto use the pattern <CATEGORY>-NNN (no vendor infix).

---

## Gap Analysis vs. Existing Policies

The Palo Alto policy set has rules implemented across management, threat, zone, policy, and operational domains. Rules gate on licensing (via panos_system_info) and on full-config availability (SNMP-only exports are skipped).

### Implemented Rules

**Management Plane (paloalto_management.rego):**
- SEC-PA-001: Idle timeout configured
- SEC-PA-002: Password complexity enforcement
- SEC-PA-003: Login banner set
- SEC-PA-004: Syslog logging configured
- SEC-PA-005: Permitted IP on mgmt interface
- SEC-PA-006: NTP configured
- SEC-PA-007: SNMPv3 used (not v2c)
- SEC-PA-008: HTTP/Telnet disabled on mgmt
- SEC-PA-009: Account lockout configured
- SEC-PA-010: External authentication (RADIUS/TACACS+/LDAP)

**Threat Prevention (paloalto_threat.rego)** — all gated on license + full config:
- TP-PA-001: WildFire analysis profile (requires WildFire license)
- TP-PA-002: Antivirus profile (requires AV license)
- TP-PA-003: Anti-Spyware profile (requires Threat license)
- TP-PA-004: Vulnerability Protection profile (requires Threat license)
- TP-PA-005: URL Filtering profile (requires URL license)
- TP-PA-006: DNS Security enabled (requires Threat license)
- TP-PA-007: WildFire real-time updates enabled (requires WildFire license)

**Zone Protection (paloalto_zone.rego):**
- ZP-PA-001: Zone protection profile applied
- ZP-PA-002: SYN flood protection enabled
- ZP-PA-003: Packet-based attack protection enabled

**Security Policy (paloalto_policy.rego):**
- SEC-PA-020: Security profile group on allow rules
- SEC-PA-021: Logging at session end
- SEC-PA-022: SSL/TLS decryption (Advisory)
- SEC-PA-023: Explicit deny-all rule
- SEC-PA-024: File blocking profile
- SEC-PA-025: No overly permissive any/any rules
- HA-PA-001: HA configured (Advisory)

**Operational (paloalto_operational.rego)** — uses `show system info` data:
- AVL-PA-001: Threat Prevention license active
- AVL-PA-002: WildFire license active
- AVL-PA-003: URL Filtering license active
- AVL-PA-004: AV signatures current (>7 day staleness)
- AVL-PA-005: Threat signatures current (>7 day staleness)
- AVL-PA-006: WildFire signatures current (>1 day staleness)
- AVL-PA-007: WildFire real-time signatures enabled
- AVL-PA-008: Device certificate valid
- AVL-PA-009: GlobalProtect deployed (Advisory)
- PERF-PA-001: PAN-OS version on supported train

### Remaining Gaps
- Default admin password changed (not detectable from config)
- Password change period and reuse limits
- Valid HTTPS certificate for admin interface
- Log on high DP load enabled
- Redundant NTP servers (currently checks for any NTP)
- Verify update server identity
- Admin roles and MFA
- Reconnaissance protection enabled (zone protection)
- Anti-spoofing in zone protection
- User-ID security (internal zones only, Include/Exclude, Agent perms)
- HA link/path monitoring, passive link state
- AV/Threat update schedules (hourly/daily)
- WildFire upload limits maximized
- Decrypted content forwarded to WildFire
- PAN-DB vs BrightCloud
- URL category blocking actions and logging
- Trusted decryption certificate
- Decryption profile TLS/cipher restrictions
- HA sync status validation (requires show high-availability state)
- Session table utilization (requires show session info)
- Dataplane/management CPU utilization (requires show running resource-monitor)
- Panorama config sync
- Certificate expiration monitoring

---

## High Availability & Updates

| Check | Best Practice | Severity | CIS Ref |
|-------|--------------|----------|---------|
| HA configured for critical deployments | Use active/passive or active/active HA | High | — |
| Dynamic updates enabled | Enable automatic content updates | High | — |
| Software updates current | Run latest stable PAN-OS version | High | — |
| Application and threat database current | Update App-ID and threat signatures regularly | High | — |

---

## Compliance & Hardening Checklists

### CIS Benchmark Highlights (v1.3.0 for PAN-OS 10, v1.1.0 for PAN-OS 11)

- **1.3.x** Password complexity (length, uppercase, lowercase, numeric, special, rotation, reuse)
- **1.4.x** Idle timeout, failed login lockout
- **2.x** Management interface hardening (HTTPS, SSH only, permitted IPs, dedicated network)
- **3.x** Logging (log forwarding, session-end logging, threat logs)
- **4.x** Security profiles (antivirus, anti-spyware, vulnerability protection, URL filtering)
- **5.x** Security policy (default deny, no "any" rules, descriptions, tags, session-end logging)

### NIST CSF Alignment

- **Identify (ID):** Asset management, security zones
- **Protect (PR):** Security profiles, access control, logging
- **Detect (DE):** Threat logs, URL filtering logs, SIEM integration
- **Respond (RS):** Incident response, HA failover
- **Recover (RC):** Backup/restore, HA recovery

---

**Usage Notes:**

- **For OPA Rego policies:** Parse XML/JSON exports from PAN-OS API or `show config running` output.
- **For audits:** Use this reference as a checklist; mark each item as Pass/Fail/Manual Review.
- **For reporting:** Include CIS Ref, Severity, Current State, Gap, and Recommended Action for each finding.
