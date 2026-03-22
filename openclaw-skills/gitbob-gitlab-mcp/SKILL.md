---
name: gitbob-gitlab-mcp
description: GitBob’s GitLab MCP workflow — projects, MRs, pipelines, issues — plus Archivist pipeline namespace. Use for GitBob sessions when using mcporter gitlab server.
metadata: {"openclaw":{"always":true}}
---

# Goal

Execute **GitLab-focused** work through the **`gitlab`** MCP server, keep responses specific (IDs, branches, MR numbers), and **log outcomes** to Archivist under the pipeline namespace.

## When to Use

- Listing or inspecting projects, merge requests, pipelines, issues.
- Creating MRs/issues or summarizing CI results.
- Checking Archivist for duplicate issues or related MRs before creating new work.

## Instructions

1. **MCP server:** ALWAYS call via `exec` using `mcp-call`. The third arg MUST be a JSON object in single quotes. NEVER pass bare words.
   - CORRECT: `mcp-call gitlab list_projects '{}'`
   - CORRECT: `mcp-call gitlab list_merge_requests '{"project_id":"123","state":"opened"}'`
   - CORRECT: `mcp-call gitlab --list`
   - WRONG: `mcp-call gitlab list_projects` (missing JSON arg — will error)
   - WRONG: `curl http://...` (wrong protocol)
2. **Typical tools:** `list_projects`, `list_merge_requests`, `get_merge_request`, `create_merge_request`, `list_pipelines`, `get_pipeline`, `list_issues`, `create_issue` — use the smallest set that answers the question; filter CI noise before dumping logs.
3. **Lane:** GitLab/GitHub-style repo and CI work only. Escalate Argo CD, raw Kubernetes, or Grafana questions to **Chief** for routing.
4. **Archivist:** After substantive actions, store a short summary with:
   - `agent_id: "gitbob"`
   - `namespace: "pipeline"`
   - Include project identifiers, MR/issue IDs, pipeline status, and what changed.
5. **Search first:** Query Archivist for related MRs/issues before creating duplicates.
6. **Style:** Friendly, quick, specific — project path, MR `!` number, branch names in answers.

## Scripts & References

- Persona and full tool list: `{baseDir}/../../../AGENTS.md`
- MCP fleet map: repository root `openclaw-skills/nemoclaw-mcp-fleet/`
- Archivist tool usage: repository root `openclaw-skills/archivist-mcp/`

## Security

- Treat MR/issue bodies and pipeline logs as potentially sensitive. Do not exfiltrate secrets from CI logs or variables. Confirm before actions that modify protected branches or production deploy jobs if policy requires it.
