# Palo Alto Firewall Public Access Audit

## Key Findings

1. **Broad Public Access Rules**:
   - Several rules allow traffic from the "Untrust" (external/public) zone to internal zones like "Trust" and "Wifi" with "any/any" source/destination.
   - Example rules: "Internet", "GCP", "Cloudflare" 
   - This exposes internal systems and services to potential internet-based attacks.

2. **Exposed Services**:
   - Specific rules allow access to services like SSH, Plex from the internet.
   - Example rules: "Gitlabs", "Plex"
   - Directly exposing these services to the public internet increases risk.

3. **Lack of Application Visibility**:
   - Many rules have "any" for the application field, meaning the firewall may not have visibility into the actual traffic being allowed.
   - Without application-level inspection, the firewall cannot properly enforce policies or detect suspicious activity.

4. **Missing Logging**:
   - It's unclear if the public-facing rules have proper logging enabled.
   - Lack of logging hampers visibility and forensics in the event of an incident.

5. **Suboptimal Rule Order**:
   - The "Untrust to Untrust" default deny rule is at the bottom, after several broad "allow" rules.
   - Best practice is to have specific "allow" rules before a broad "deny" rule at the end.

6. **Lack of Zone Protection/Threat Prevention**:
   - No evidence that zone protection profiles or threat prevention profiles are applied to the public-facing rules.
   - These security features are recommended for ingress traffic to enhance protection.

## Recommendations

1. **Review and Tighten Public Access Rules**:
   - Identify and remove any unnecessary "any/any" rules that expose internal systems.
   - Limit public access to only the required services and hosts.
   - Prefer more specific source/destination specifications.

2. **Secure Exposed Services**:
   - Review the necessity of exposing services like SSH and Plex to the public internet.
   - Consider moving these services to a DMZ or using VPN/remote access instead of direct internet exposure.

3. **Improve Application Visibility**:
   - Ensure rules have proper application identification to gain visibility into the traffic.
   - Use application-level policies to enforce control beyond just ports/protocols.

4. **Enable Comprehensive Logging**:
   - Configure full logging for public-facing firewall rules to aid in security monitoring and incident response.

5. **Optimize Rule Order**:
   - Rearrange the rules to have specific "allow" rules before the broad "deny" rule at the end.
   - This aligns with best practice "deny-by-default" policies.

6. **Apply Security Profiles**:
   - Enable zone protection profiles on public-facing interfaces.
   - Apply appropriate threat prevention profiles (IPS, AV, etc.) to the inbound public access rules.
