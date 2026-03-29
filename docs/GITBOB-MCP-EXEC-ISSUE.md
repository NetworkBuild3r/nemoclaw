# GitBob MCP Execution Issue — OpenClaw Agent Sessions

## Problem

GitBob (OpenClaw agent via Telegram) cannot execute the `mcp-call` helper script to call GitLab MCP tools. The script works fine from your shell but fails when Bob tries to run it via OpenClaw's `exec` tool.

## Why this happens

**OpenClaw agents via Telegram** use the `exec` tool to run shell commands, but there are restrictions:

1. **Path resolution:** The agent may not have the same `PATH` or working directory as your shell
2. **Permissions:** The OpenClaw gateway process user may not have execute permissions on the script
3. **Environment:** `python3`, `MCPPORTER_JSON`, and other dependencies may not be in the agent's runtime environment

## Solution 1: Add `mcp-call` to PATH for the gateway user

The OpenClaw gateway runs as a systemd user service. Ensure `mcp-call.sh` is on `PATH`:

```bash
# Create a bin directory if it doesn't exist
mkdir -p ~/.local/bin

# Symlink mcp-call into PATH
ln -sf /home/bnelson/nemoclaw/scripts/mcp-call.sh ~/.local/bin/mcp-call

# Verify PATH includes ~/.local/bin (should be automatic on Ubuntu)
echo $PATH | grep -q "$HOME/.local/bin" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Restart gateway to pick up environment
systemctl --user restart openclaw-gateway.service
```

## Solution 2: Use absolute paths in Bob's AGENTS.md

Update [`agents/github-bob/AGENTS.md`](../agents/github-bob/AGENTS.md) to use **absolute paths** for `mcp-call`:

```markdown
CORRECT usage:

    /home/bnelson/nemoclaw/scripts/mcp-call.sh gitlab list_projects '{}'
    /home/bnelson/nemoclaw/scripts/mcp-call.sh gitlab --list
```

Then restart the gateway so Bob's session picks up the updated instructions.

## Solution 3: mcporter integration (native MCP client)

OpenClaw has a native MCP client library (`mcporter`) that can be used directly instead of the shell script. This requires modifying Bob's workspace or OpenClaw's agent runtime to use the Node.js MCP client.

This is more complex but would eliminate the `exec` dependency entirely.

## Solution 4: Run Bob in a NemoClaw sandbox with proper policies

If Bob were running in a **NemoClaw sandbox** with the `mcp_aggregator` policy applied, he would have:

1. Network egress to `192.168.11.160:8080` (the aggregator)
2. Approved binaries: `/usr/bin/curl`, `/usr/local/bin/node`, etc.
3. The `mcp-call` script accessible at a known path

However, Bob is currently running **on the host** (per `openclaw.json` — no sandbox config). To move him to a sandbox:

1. Create a NemoClaw sandbox for Bob (or use the existing `openclaw` sandbox)
2. Apply the `mcp_aggregator` policy preset
3. Update Bob's `agentDir` to point into the sandbox workspace
4. Restart the gateway

## Recommended short-term fix

**Solution 1** (add to PATH) is the quickest and least invasive. Test after restart:

```bash
# From your shell (as the gateway user)
which mcp-call
# Should output: /home/bnelson/.local/bin/mcp-call

# Then ask Bob to try again via Telegram
```

## Related

- GitLab MCP authorization issue: [`GITLAB-MCP-AUTH-ISSUE.md`](GITLAB-MCP-AUTH-ISSUE.md)
- mcp-call script: [`/home/bnelson/nemoclaw/scripts/mcp-call.sh`](../scripts/mcp-call.sh)
- Bob's persona: [`agents/github-bob/AGENTS.md`](../agents/github-bob/AGENTS.md)
