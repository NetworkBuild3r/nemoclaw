# GitLab MCP Status — RESOLVED (with caveats)

## ✅ Authorization: WORKING

**Status update (2026-03-26 10:15):** The GitLab MCP authorization issue is **RESOLVED**. The MCP server now successfully authenticates to GitLab and returns data.

### What happened

After the aggregator restart, the GitLab MCP at `http://192.168.11.160:8080/gitlab/mcp` started working. Direct curl test returned **393 KB of project data** (successful authentication).

The "Unauthorized" error Bob saw earlier is **gone**. The MCP has valid GitLab credentials and can access the GitLab API.

## ⚠️  New issue: Response size

The GitLab MCP returns **all accessible projects** (393 KB) when calling `list_projects`, even with `perPage` limits. This causes:

```bash
/home/bnelson/anaconda3/bin/python3: Argument list too long
```

The `mcp-call` script tries to pass the huge JSON through Python's command-line args, which hits OS limits (~2MB on Linux).

### Workarounds

1. **Use `search` parameter** to filter:
   ```bash
   mcp-call gitlab list_projects '{"search":"your-project-name"}'
   ```

2. **Use project-specific tools** instead of `list_projects`:
   ```bash
   # If you know the project ID/path:
   mcp-call gitlab get_project '{"projectId":"group/project"}'
   mcp-call gitlab list_merge_requests '{"projectId":"123","state":"opened"}'
   ```

3. **Fix the mcp-call script** to write JSON to a temp file instead of passing via args (see below)

## Recommended fix: Update mcp-call.sh

The script at line 88 has:
```bash
python3 -c "..." "$response"
```

This should write `$response` to a temp file and read from stdin instead:

```bash
echo "$response" | python3 -c "import json,sys; ..."
```

Or use Python's `-` stdin convention.

## Architecture context

The GitLab MCP is deployed somewhere in your cluster (ArgoCD-managed from `git@github.com:NetworkBuild3r/home_k3.git`). It now has valid credentials and successfully authenticates to GitLab.

## Fix for "Argument list too long"

Update [`scripts/mcp-call.sh`](../scripts/mcp-call.sh) around line 88 to use stdin instead of command args for large responses:

```bash
# OLD (fails on large responses):
python3 -c "import json,sys; ..." "$response"

# NEW (handles any size):
echo "$response" | python3 -c "import json,sys; d=json.load(sys.stdin); ..."
```

This will allow Bob to call `list_projects` even when GitLab returns hundreds of projects.

## Status

- **Auth:** ✅ Working
- **Bob can exec:** ✅ Fixed (PATH symlink)
- **Response size:** ⚠️  Needs mcp-call.sh update or workaround

## References

- Vault path: `kv/nemoclaw/project-env` → `GITLAB_TOKEN`
- ArgoCD source: `git@github.com:NetworkBuild3r/home_k3.git` (external; you own it per findings)
- Aggregator wiring: [`deploy/k8s/mcp-aggregator/README.md`](deploy/k8s/mcp-aggregator/README.md)
- GitBob skill: [`openclaw-skills/gitbob-gitlab-mcp/SKILL.md`](openclaw-skills/gitbob-gitlab-mcp/SKILL.md)
