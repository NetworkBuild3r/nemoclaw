# Synology DSM — Reference

## Common Ports

| Service | Default Port | Notes |
|---------|-------------|-------|
| **DSM Web (HTTP)** | 5000 | Redirect to HTTPS in most setups |
| **DSM Web (HTTPS)** | 5001 | Admin interface |
| **SSH** | 22 | Enable via Control Panel → Terminal & SNMP |
| **SMB/CIFS** | 445, 139 | Windows file sharing |
| **AFP** | 548 | Apple file sharing (deprecated in DSM 7+) |
| **NFS** | 2049 | Unix/Linux file sharing |
| **FTP** | 21 | Enable via Package Center |
| **SFTP** | 22 | Uses SSH |
| **WebDAV** | 5005 (HTTP), 5006 (HTTPS) | Enable via File Station |
| **Rsync** | 873 | For backup/sync |

## DSM API Documentation

**Official:**
- Synology Developer Portal: https://www.synology.com/en-global/support/developer
- DSM API Guide (requires Synology account): https://global.download.synology.com/download/Document/Software/DeveloperGuide/

**Community:**
- Unofficial API docs (GitHub): https://github.com/kwent/syno
- Python Synology API wrapper: https://github.com/N4S4/synology-api

**API Discovery:**
```bash
# List available APIs on your NAS
curl -k "https://nas.example.com:5001/webapi/query.cgi?api=SYNO.API.Info&version=1&method=query&query=all"
```

## SSH Hardening Checklist

- [ ] Disable root login: edit `/etc/ssh/sshd_config` → `PermitRootLogin no`
- [ ] Use key-based auth: disable password auth when keys are set up
- [ ] Change default SSH port (optional): Control Panel → Terminal & SNMP
- [ ] Enable auto-block: DSM Control Panel → Security → Protection → Enable auto-block
- [ ] Limit SSH access by IP: Control Panel → Security → Firewall
- [ ] Review admin group members: only trusted users should have sudo
- [ ] Enable 2FA: DSM Control Panel → Security → Account → 2-factor authentication
- [ ] Monitor auth logs: `sudo tail -f /var/log/auth.log`

## Backup Verification Scripts

### Check HyperBackup Task Status

```bash
#!/bin/bash
# List all HyperBackup tasks and their last run status
ssh admin@nas.example.com "sudo /var/packages/HyperBackup/target/bin/backuptask --list" | \
  while read task; do
    echo "Task: $task"
    ssh admin@nas.example.com "sudo /var/packages/HyperBackup/target/bin/backuptask --info $task"
  done
```

### Snapshot Age Check

```bash
#!/bin/bash
# Alert if latest snapshot is older than 24 hours
LATEST=$(ssh admin@nas.example.com "sudo /usr/syno/bin/synosnap --list" | tail -1 | awk '{print $3}')
AGE=$(( $(date +%s) - $(date -d "$LATEST" +%s) ))
if [ $AGE -gt 86400 ]; then
  echo "WARNING: Latest snapshot is $((AGE/3600)) hours old"
fi
```

### Disk Health Summary

```bash
#!/bin/bash
# Check SMART status for all drives
ssh admin@nas.example.com "sudo /usr/syno/bin/synostg --health" | \
  grep -E "(Drive|Health)" | \
  awk 'NR%2{printf "%s ",$0;next;}1'
```

## Common DSM CLI Tools

| Tool | Purpose |
|------|---------|
| `/usr/syno/bin/synospace` | Storage pool management |
| `/usr/syno/bin/synoshare` | Shared folder operations |
| `/usr/syno/bin/synoservice` | Service control |
| `/usr/syno/bin/synoservicectl` | Service enumeration |
| `/usr/syno/bin/synofirewall` | Firewall rules |
| `/usr/syno/bin/synosnap` | Snapshot management |
| `/usr/syno/bin/synostg` | Storage health checks |
| `synopkg` | Package management |
| `/usr/syno/bin/synouser` | User management |
| `/usr/syno/bin/synogroup` | Group management |

**Note:** Most require `sudo` or root privileges.

## Example: Daily Health Report

```bash
#!/bin/bash
# Generate daily NAS health report

NAS="admin@nas.example.com"
REPORT="/tmp/nas-health-$(date +%Y%m%d).txt"

{
  echo "=== Synology NAS Health Report ==="
  echo "Generated: $(date)"
  echo ""
  
  echo "--- System Info ---"
  ssh $NAS "cat /etc.defaults/VERSION"
  ssh $NAS "uptime"
  echo ""
  
  echo "--- Disk Usage ---"
  ssh $NAS "df -h"
  echo ""
  
  echo "--- RAID Status ---"
  ssh $NAS "cat /proc/mdstat"
  echo ""
  
  echo "--- SMART Health ---"
  ssh $NAS "sudo /usr/syno/bin/synostg --health"
  echo ""
  
  echo "--- Failed Logins (last 24h) ---"
  ssh $NAS "sudo grep 'Failed password' /var/log/auth.log | tail -20"
  echo ""
  
  echo "--- Package Updates Available ---"
  ssh $NAS "synopkg list --full | grep 'upgradable=yes'"
  
} > $REPORT

echo "Report saved to $REPORT"
```

## Known Issues / Gotchas

- **DSM 7.x changes:** AFP deprecated, some CLI paths changed, new permission model
- **Custom ports:** if DSM runs on non-standard ports, update firewall and connection strings
- **Btrfs vs ext4:** Btrfs volumes support snapshots/dedup; ext4 do not
- **Package dependencies:** some packages require others (e.g., Docker needs Container Manager)
- **API session timeouts:** default 15 min idle; may need to re-auth for long-running scripts
- **Sudo timeout:** DSM may prompt for password again after 5 min; use `NOPASSWD` in sudoers for service accounts (with caution)

## Further Reading

- Synology Knowledge Base: https://kb.synology.com
- DSM Release Notes: https://www.synology.com/en-us/releaseNote/DS920+
- Synology Community Forums: https://community.synology.com
- Unofficial CLI reference: https://github.com/Khad-Kadboor/synology-cli
