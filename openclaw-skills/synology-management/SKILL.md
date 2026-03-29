# Synology NAS / DSM Administration

**name:** synology-management

Manage Synology NAS devices running DiskStation Manager (DSM) — SSH access, system info, storage monitoring, service control, package management, and basic configuration audits.

## Overview

Synology DiskStation Manager (DSM) is a Linux-based NAS operating system. This skill covers:
- SSH connection and command execution
- Storage pool and volume monitoring
- Service and package management (via `synopkg`, `synoservice`)
- User and permission audits
- Backup and snapshot verification
- Basic security hardening checks

## When to Use This Skill

- **System health checks:** disk status, volume capacity, RAID health
- **Service management:** start/stop/restart DSM services (e.g., SSH, SMB, NFS)
- **Package operations:** list installed packages, update, install/remove
- **Configuration audits:** verify firewall rules, user permissions, shared folder settings
- **Backup verification:** check HyperBackup status, snapshot schedules
- **Troubleshooting:** logs, network connectivity, resource usage

**Do not use for:**
- Secrets management (use Vault or external secrets manager)
- Complex storage configuration changes (do those via DSM UI or with human confirmation)
- Destructive operations without explicit approval

## Prerequisites

- **SSH access:** DSM admin user with SSH enabled (Control Panel → Terminal & SNMP → Enable SSH)
- **Key-based auth recommended:** add your public key to `~/.ssh/authorized_keys` on the NAS
- **Sudo/root:** some commands require `sudo` (admin group users can sudo on DSM)
- **Network:** reachable from your OpenClaw host (direct or VPN)

## Common Patterns

### Connection & System Info

```bash
# Test SSH connectivity
ssh admin@nas.example.com "uname -a"

# DSM version
ssh admin@nas.example.com "cat /etc.defaults/VERSION"

# Current uptime and load
ssh admin@nas.example.com "uptime"

# Disk usage summary
ssh admin@nas.example.com "df -h"
```

### Storage & RAID Health

```bash
# Storage pool status (requires root)
ssh admin@nas.example.com "sudo /usr/syno/bin/synospace --show"

# RAID array status
ssh admin@nas.example.com "cat /proc/mdstat"

# Volume list
ssh admin@nas.example.com "sudo /usr/syno/bin/synoshare --getall"

# SMART health for all drives
ssh admin@nas.example.com "sudo /usr/syno/bin/synostg --health"
```

### Service Management

```bash
# List all services
ssh admin@nas.example.com "sudo /usr/syno/bin/synoservicectl --list"

# Service status (e.g., SMB)
ssh admin@nas.example.com "sudo /usr/syno/bin/synoservice --status smbd"

# Restart a service
ssh admin@nas.example.com "sudo /usr/syno/bin/synoservice --restart smbd"
```

### Package Management

```bash
# List installed packages
ssh admin@nas.example.com "synopkg list --full"

# Package info
ssh admin@nas.example.com "synopkg info <package_name>"

# Start/stop package
ssh admin@nas.example.com "sudo synopkg start <package_name>"
ssh admin@nas.example.com "sudo synopkg stop <package_name>"
```

### User & Permission Audits

```bash
# List local users
ssh admin@nas.example.com "cat /etc/passwd | grep -E '/var/services/homes'"

# Shared folder permissions
ssh admin@nas.example.com "sudo /usr/syno/bin/synoshare --enum"

# Check admin group members
ssh admin@nas.example.com "getent group administrators"
```

### Security & Firewall

```bash
# Firewall status
ssh admin@nas.example.com "sudo /usr/syno/bin/synofirewall --status"

# List firewall rules
ssh admin@nas.example.com "sudo /usr/syno/bin/synofirewall --list"

# Check failed SSH login attempts
ssh admin@nas.example.com "sudo cat /var/log/auth.log | grep 'Failed password'"
```

### Backup & Snapshot Verification

```bash
# List active backup tasks (HyperBackup CLI if installed)
ssh admin@nas.example.com "sudo /var/packages/HyperBackup/target/bin/backuptask --list"

# List snapshots (Snapshot Replication)
ssh admin@nas.example.com "sudo /usr/syno/bin/synosnap --list"
```

### Logs

```bash
# System log (last 50 lines)
ssh admin@nas.example.com "sudo tail -50 /var/log/messages"

# SSH log
ssh admin@nas.example.com "sudo tail -50 /var/log/auth.log"

# Package installation log
ssh admin@nas.example.com "sudo cat /var/log/synopkg.log"
```

## DSM API (Web API)

DSM exposes a REST API for many operations. Access requires login with username/password (or session token).

**Common endpoints:**
- **Auth:** `POST /webapi/auth.cgi?api=SYNO.API.Auth&version=3&method=login`
- **System Info:** `POST /webapi/entry.cgi?api=SYNO.Core.System&version=1&method=info`
- **Storage:** `POST /webapi/entry.cgi?api=SYNO.Core.Storage&version=1&method=list`
- **Package Center:** `POST /webapi/entry.cgi?api=SYNO.Core.Package&version=2&method=list`

**Example (curl):**
```bash
# Login
curl -X POST "https://nas.example.com:5001/webapi/auth.cgi" \
  --data "api=SYNO.API.Auth&version=3&method=login&account=admin&passwd=<password>&session=Core&format=sid"

# System info (with session ID)
curl -X POST "https://nas.example.com:5001/webapi/entry.cgi?_sid=<sid>" \
  --data "api=SYNO.Core.System&version=1&method=info"
```

**Security notes:**
- Never log passwords in plaintext
- Use environment variables for credentials
- Consider using API accounts with limited permissions
- Prefer SSH key auth over password-based API calls when possible

## References

See [`references/REFERENCE.md`](references/REFERENCE.md) for:
- Common DSM ports
- DSM API documentation links
- SSH hardening checklist
- Backup verification scripts

## Safety & Best Practices

1. **Read-only by default:** prefer queries over mutations
2. **Confirm destructive ops:** service restarts, package removes, volume changes
3. **Log actions:** record what you ran and when (use Archivist or session logs)
4. **No secrets in skills:** use Vault or environment variables for credentials
5. **Test on non-production first:** when trying new commands
6. **Human approval for:**
   - Storage pool or volume modifications
   - Firewall rule changes
   - User account creation/deletion
   - Package installations that aren't explicitly requested

## Troubleshooting

**SSH connection refused:**
- Check SSH is enabled: DSM Control Panel → Terminal & SNMP
- Verify port (default 22, or custom port)
- Check firewall rules on NAS and network

**Permission denied:**
- User must be in `administrators` group for sudo
- Some commands require `sudo` prefix
- Key-based auth may not be set up (check `~/.ssh/authorized_keys`)

**Command not found:**
- DSM uses custom paths: `/usr/syno/bin/`, `/var/packages/*/target/`
- Check if package is installed: `synopkg list`

**API returns error:**
- Verify session ID is valid (may expire)
- Check API version (DSM updates may change versions)
- Use `/webapi/entry.cgi` for most modern APIs

## Related Skills

- **`vault-secrets`** — for storing NAS credentials
- **`git-reports-marketing`** — if generating NAS health reports
- **`mcp-builder`** — if building a custom DSM MCP server
- **`skill-builder`** — for extending this skill with new patterns

## Changelog

- **2026-03-26:** Initial skill draft (coverage: SSH, storage, services, packages, API basics)
