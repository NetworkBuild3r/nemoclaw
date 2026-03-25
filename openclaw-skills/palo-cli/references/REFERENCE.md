# PAN-OS CLI & XML API — Reference Material

Detailed XPath cheat sheet, XML API parameters, operational command templates, response parsing, and troubleshooting for the `palo-cli` skill.

---

## PAN-OS XML API Basics

The paloalto MCP server calls the PAN-OS XML API at `GET /api/` with query parameters. The three `type` values used:

| `type` | Purpose | Key Params |
|--------|---------|------------|
| `op` | Operational commands (`show`, `request`, `test`) | `cmd` — XML-encoded CLI command |
| `config` | Configuration read/write | `action` (`get`\|`show`\|`set`\|`edit`\|`delete`), `xpath` |
| `keygen` | Generate API key from credentials | `user`, `password` |

The MCP server only uses `type=op` (for `panos_show_system_info`) and `type=config&action=get` (for `panos_list_security_rules` and `panos_config_get`). All calls are read-only.

### `action=get` vs `action=show`

- **`get`** — returns the full XML node including default values and inherited config.
- **`show`** — returns only the effective/active config (what's running). Use `get` for auditing completeness; use `show` for operational state.

---

## XPath Cheat Sheet

All XPaths start from `/config/`. The device entry prefix for single-vsys is:

```
/config/devices/entry[@name='localhost']/vsys/entry[@name='vsys1']
```

Abbreviated below as `{vsys1}`.

### Device & Management

| What | XPath |
|------|-------|
| System settings | `/config/devices/entry[@name='localhost']/deviceconfig/system` |
| Password complexity | `/config/devices/entry[@name='localhost']/deviceconfig/setting/management/password-complexity` |
| Management interface | `/config/devices/entry[@name='localhost']/deviceconfig/system/permitted-ip` |
| Admin lockout | `/config/devices/entry[@name='localhost']/deviceconfig/setting/management/admin-lockout` |
| Authentication profile | `{vsys1}/authentication-profile` |
| Log settings | `{vsys1}/log-settings` |
| Syslog server profiles | `{vsys1}/log-settings/syslog` |
| SNMP setup | `/config/devices/entry[@name='localhost']/deviceconfig/system/snmp-setting` |
| NTP servers | `/config/devices/entry[@name='localhost']/deviceconfig/system/ntp-servers` |
| Login banner | `/config/devices/entry[@name='localhost']/deviceconfig/system/login-banner` |
| HA config | `/config/devices/entry[@name='localhost']/deviceconfig/high-availability` |

### Network

| What | XPath |
|------|-------|
| All interfaces | `/config/devices/entry[@name='localhost']/network/interface` |
| Ethernet interfaces | `.../network/interface/ethernet` |
| Tunnel interfaces | `.../network/interface/tunnel` |
| Loopback interfaces | `.../network/interface/loopback` |
| Virtual routers | `/config/devices/entry[@name='localhost']/network/virtual-router` |
| DNS proxy | `/config/devices/entry[@name='localhost']/network/dns-proxy` |

### Zones

| What | XPath |
|------|-------|
| All zones | `{vsys1}/zone` |
| Specific zone | `{vsys1}/zone/entry[@name='untrust']` |
| Zone protection profiles | `{vsys1}/zone/entry[@name='untrust']/network/zone-protection-profile` |

### Security Policy

| What | XPath |
|------|-------|
| Security rules (local) | `{vsys1}/rulebase/security/rules` |
| Security rules (shared) | `/config/shared/rulebase/security/rules` |
| Specific rule | `{vsys1}/rulebase/security/rules/entry[@name='allow-dns']` |
| NAT rules | `{vsys1}/rulebase/nat/rules` |
| Decryption rules | `{vsys1}/rulebase/decryption/rules` |
| Application override | `{vsys1}/rulebase/application-override/rules` |

### Objects

| What | XPath |
|------|-------|
| Address objects | `{vsys1}/address` |
| Address groups | `{vsys1}/address-group` |
| Service objects | `{vsys1}/service` |
| Service groups | `{vsys1}/service-group` |
| Application groups | `{vsys1}/application-group` |
| Application filters | `{vsys1}/application-filter` |
| Tags | `{vsys1}/tag` |
| External dynamic lists | `{vsys1}/external-list` |

### Security Profiles

| What | XPath |
|------|-------|
| Antivirus profiles | `{vsys1}/profiles/virus` |
| Anti-spyware profiles | `{vsys1}/profiles/spyware` |
| Vulnerability protection | `{vsys1}/profiles/vulnerability` |
| URL filtering | `{vsys1}/profiles/url-filtering` |
| File blocking | `{vsys1}/profiles/file-blocking` |
| WildFire analysis | `{vsys1}/profiles/wildfire-analysis` |
| Security profile groups | `{vsys1}/profile-group` |
| DNS security | `{vsys1}/profiles/dns-security` |
| Data filtering | `{vsys1}/profiles/data-filtering` |
| Decryption profiles | `{vsys1}/profiles/decryption` |

### Log Forwarding

| What | XPath |
|------|-------|
| Log forwarding profiles | `{vsys1}/log-settings/profiles` |
| System log settings | `/config/devices/entry[@name='localhost']/deviceconfig/setting/logging` |
| Syslog server profile | `{vsys1}/log-settings/syslog` |

### GlobalProtect & VPN

| What | XPath |
|------|-------|
| GP portal | `{vsys1}/global-protect/global-protect-portal` |
| GP gateway | `{vsys1}/global-protect/global-protect-gateway` |
| IKE gateways | `/config/devices/entry[@name='localhost']/network/ike/gateway` |
| IPSec tunnels | `.../network/tunnel/ipsec` |
| IKE crypto profiles | `.../network/ike/crypto-profiles` |

### User-ID

| What | XPath |
|------|-------|
| User-ID config | `{vsys1}/user-id-agent` |
| User-ID include/exclude | `{vsys1}/user-id-agent/entry[@name='...']/host-port/include-network` |
| Group mapping | `{vsys1}/group-mapping` |

---

## Operational Command XML Templates

These are XML-encoded `cmd` values for `type=op` requests. The MCP server currently only implements `show system info`, but these are the standard PAN-OS operational commands for reference and future MCP tool expansion.

### System & Status

```xml
<show><system><info></info></system></show>
```

```xml
<show><system><resources></resources></system></show>
```

```xml
<show><high-availability><state></state></high-availability></show>
```

### Sessions & Performance

```xml
<show><session><info></info></session></show>
```

```xml
<show><session><all><filter><destination>10.0.0.1</destination></filter></all></session></show>
```

```xml
<show><running><resource-monitor></resource-monitor></running></show>
```

### Routing & ARP

```xml
<show><routing><route></route></routing></show>
```

```xml
<show><arp><entry name="all"></entry></arp></show>
```

```xml
<show><interface>all</interface></show>
```

### Threat & Content

```xml
<show><system><info></info></system></show>
<!-- content-version, app-version, threat-version, wildfire-version in response -->
```

```xml
<test><wildfire><registration></registration></wildfire></test>
```

### Counters & Logs

```xml
<show><counter><global></global></counter></show>
```

```xml
<show><counter><global><filter><severity>drop</severity></filter></global></counter></show>
```

```xml
<show><log><traffic><query>( addr.src in 10.0.0.0/8 )</query></traffic></log></show>
```

### Certificates

```xml
<show><sslmgr-store><config-certificate-info></config-certificate-info></sslmgr-store></show>
```

---

## Response Parsing Patterns

### Successful response

```json
{
  "response": {
    "status": "success",
    "result": {
      "system": {
        "hostname": "fw01",
        "model": "PA-850",
        "sw-version": "10.2.3",
        "serial": "00123456789",
        "uptime": "45 days, 12:30:15"
      }
    }
  }
}
```

Navigate: `response.result.system.hostname`

### Config get — list of entries

```json
{
  "response": {
    "status": "success",
    "result": {
      "entry": [
        { "@name": "allow-dns", "action": "allow", "from": { "member": ["trust"] } },
        { "@name": "deny-all", "action": "deny" }
      ]
    }
  }
}
```

Entries are under `response.result.entry[]`. Each entry has `@name` as the identifier.

### Single entry (specific xpath)

```json
{
  "response": {
    "status": "success",
    "result": {
      "entry": { "@name": "untrust", "network": { "layer3": { "member": ["ethernet1/1"] } } }
    }
  }
}
```

When querying a single `entry[@name='...']`, result is an object (not array).

### Error response

```json
{
  "response": {
    "status": "error",
    "result": {
      "msg": "Invalid xpath: /config/bad/path"
    }
  }
}
```

Check `response.status` first. On `"error"`, `result.msg` has the diagnostic.

### Mock mode response

```json
{
  "response": {
    "status": "success",
    "result": {
      "system": {
        "hostname": "pan-mock",
        "model": "PA-VM",
        "sw-version": "11.1.0"
      }
    }
  }
}
```

Mock returns minimal synthetic data. The hostname `pan-mock` and model `PA-VM` are mock indicators.

---

## Common Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `{"error": "unknown tool ..."}` | Tool name typo | Use `mcp-call paloalto --list` to verify exact names |
| `status: "error"`, invalid xpath | Bad XPath syntax or missing node | Verify quoting; use the cheat sheet above |
| Empty `result` | Node exists but has no config | Normal for unconfigured features (e.g., no GP portal) |
| Connection timeout | Firewall unreachable or `PANOS_HOST` wrong | Check MCP pod logs, verify host/port, test with `curl` |
| `pan-mock` in response | Mock mode active | `PANOS_MOCK=1` is set — unset for real data |
| `raw` key in response | Non-JSON/XML response from firewall | Usually TLS or auth issue — check `PANOS_API_KEY` or creds |
| `X-PAN-KEY` auth failure | API key expired or invalid | Regenerate key: `type=keygen&user=...&password=...` |

### XPath quoting in mcp-call

Shell quoting with nested single quotes requires escaping. Two patterns:

```bash
# Pattern 1: escaped inner quotes
mcp-call paloalto panos_config_get '{"xpath":"/config/devices/entry[@name='\''localhost'\'']/vsys/entry[@name='\''vsys1'\'']/zone"}'

# Pattern 2: double-quote the JSON, escape inner doubles
mcp-call paloalto panos_config_get "{\"xpath\":\"/config/devices/entry[@name='localhost']/vsys/entry[@name='vsys1']/zone\"}"
```

---

## MCP Server Architecture

```
mcp-servers/paloalto/
├── mcp_server.py      # Tool definitions (3 tools)
├── panos_client.py    # REST client + mock logic
├── main.py            # HTTP + SSE transport
├── requirements.txt   # Python deps (mcp, httpx)
└── Dockerfile         # Container image

deploy/k8s/paloalto-mcp/
├── deployment.yaml    # 1 replica, port 8765, PANOS_MOCK=1
├── namespace.yaml
└── kustomization.yaml
```

**Production (this fleet):** `http://192.168.11.160:8080/panos/mcp` — [`config/mcporter.json`](../../../../config/mcporter.json) `paloalto.url`. **GitLab** (`gitlab.ibhacked.us`) is for **source + container registry**, not the live MCP HTTP endpoint.

**Behind the aggregator:** upstream is usually the **`paloalto-mcp`** k8s Service → pod **`/mcp/sse`** (see `deploy/k8s/mcp-aggregator/README.md` if you see **404**).

---

## Future Tool Expansion Candidates

These config areas are common audit targets but currently require `panos_config_get` with manual XPaths. Dedicated MCP tools would simplify agent workflows:

| Candidate Tool | XPath Target | Priority |
|---------------|-------------|----------|
| `panos_list_zones` | `{vsys1}/zone` | High — needed for BPA zone checks |
| `panos_list_address_objects` | `{vsys1}/address` | High — object hygiene |
| `panos_list_service_objects` | `{vsys1}/service` | High — object hygiene |
| `panos_list_security_profiles` | `{vsys1}/profiles` + `{vsys1}/profile-group` | High — threat prevention audit |
| `panos_show_ha_state` | op: `<show><high-availability>...` | Medium — HA checks |
| `panos_show_session_info` | op: `<show><session><info>...` | Medium — capacity checks |
| `panos_list_nat_rules` | `{vsys1}/rulebase/nat/rules` | Medium — NAT audit |
| `panos_show_interfaces` | op: `<show><interface>all</interface>` | Low — network troubleshooting |
