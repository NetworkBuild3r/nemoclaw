# Palo Alto Firewall Management

This skill provides the palo-expert agent with tools to manage Palo Alto Networks firewalls via the PAN-OS CLI and API.

## Key Resources
- [PAN-OS CLI Quick Start](https://docs.paloaltonetworks.com/pan-os/10-0/pan-os-cli-quick-start.html)
- [PAN-OS API Guide](https://docs.paloaltonetworks.com/pan-os/10-0/pan-os-panorama-api.html)
- [PAN-OS Web Interface Reference](https://docs.paloaltonetworks.com/pan-os/10-0/pan-os-web-interface-reference.html)

## Supported Actions
- `exec`: Execute PAN-OS CLI commands via SSH
- `api`: Call the PAN-OS XML API for advanced management tasks
- `config`: Configure firewall settings using the web interface reference

## Usage
To use this skill, the palo-expert agent should:

1. Establish an SSH connection to the target Palo Alto firewall.
2. Use the `exec` tool to run PAN-OS CLI commands, such as:
   - `show running-config`
   - `configure`, `set`, `commit` for configuration changes
3. For more complex tasks, use the `api` tool to call the PAN-OS XML API directly.
4. Refer to the PAN-OS web interface reference for guidance on specific configuration options.

The palo-expert agent should have the necessary credentials and firewall access to perform these actions.

## Examples
```
<function_calls>
<invoke name="exec">
<parameter name="file_path">palo-alto-config.txt