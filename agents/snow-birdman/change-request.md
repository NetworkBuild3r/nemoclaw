# CHG0030009 - Apply security profiles to public-facing Palo Alto firewall rules

## Change Details
- **Short Description:** Apply security profiles to public-facing Palo Alto firewall rules
- **Description:** Deploy security profile group (antivirus, anti-spyware, vulnerability protection, WildFire) to all public-facing inbound rules on PA-850 firewall (192.168.11.16). Addresses critical gaps identified in 2026-03-26 security audit where no threat protection was enabled on internet-facing rules (GCP, cloudflare, gitlabs, plex, AHEAD ollama).

## Schedule
- **Start:** 2026-03-28 12:00:00 (Saturday midday MDT) 
- **End:** 2026-03-28 14:00:00 (2-hour window)

## Implementation Plan
1. Verify security profile group exists with: antivirus, anti-spyware, vulnerability protection, WildFire
2. Apply security profile group to inbound rules: GCP, cloudflare, gitlabs, plex, AHEAD ollama
3. Enable log-at-session-end on all modified rules
4. Commit changes to PA-850
5. Monitor firewall logs for 15 minutes post-commit
6. Verify no legitimate traffic blocked

## Backout Plan
1. Remove security profiles from modified rules
2. Restore original rule configuration (profiles: none)
3. Commit changes
4. Verify traffic flow restored

## Justification
Remediate critical security gaps from 2026-03-26 audit: zero threat protection on public-facing rules exposes internal hosts to malware, exploits, and command-and-control traffic. Security profiles provide transparent inspection with minimal performance impact.

## Risk Assessment
- **Risk Level:** Low
- **Impact:** Security profiles are transparent (inspect but don't block unless threats detected)
- **Affected Systems:** Public services on beefy-cloud, dell-plex, ROG, k3-vip, Surface (inbound traffic only)
- **Testing:** Lab-validated; security profiles standard PAN-OS feature
- **Rollback Time:** <5 minutes

## Change Type
Standard (non-emergency, pre-approved pattern)

## CI
PA-850 Firewall (192.168.11.16)