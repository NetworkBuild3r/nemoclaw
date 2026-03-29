# Change Control Ticket CHG0030009

## Justification
Enable application access for new development environment. Required for team productivity and testing workflows.

## Implementation Plan
1. Review current PA-850-EDGE-01 ruleset via GUI
2. Document existing rules in affected zone
3. Create new security rule:
   - Source: 10.1.2.0/24 (dev network)
   - Destination: 192.168.10.0/24 (internal services) 
   - Service: tcp/443, tcp/8080
   - Action: allow
   - Logging: enabled
4. Commit changes to firewall
5. Verify rule hit count after 5 minutes
6. Document rule ID and position in ruleset

## Backout Plan
1. Access PA-850-EDGE-01 GUI
2. Locate rule by ID (documented during implementation)
3. Delete rule
4. Commit changes
5. Verify traffic no longer passes
6. Confirm ruleset matches pre-change state

## Test Plan
1. Pre-change: Verify traffic from 10.1.2.0/24 is blocked (expected)
2. Post-implementation: Test connectivity from 10.1.2.3 to 192.168.10.5:443 (should succeed)
3. Check firewall logs for rule hits
4. Verify no unintended traffic allowed
5. Test backout procedure in maintenance window if needed

## Schedule
- Planned start: 2026-04-01 22:00:00 (off-hours maintenance window)
- Planned end: 2026-04-01 22:30:00 (30-minute window) 
- CAB date: 2026-03-31 14:00:00