---
name: servicenow-change-control
description: ServiceNow change control via MCP v2.2.1 — 33 tools for CAB-compliant change lifecycle (express + submit workflows, status checking, server-side validation, low-token prepare-for-review). Use when creating/managing ServiceNow change tickets for infrastructure changes.
compatibility: OpenClaw agents with servicenow MCP access; Birdman (snow-birdman)
metadata:
  version: 2.2.1
  tools: 33
  canonical_source_repo: mcp-servers/servicenow/
  note: Production images/CI may track a separate GitLab repo; do not vendor that clone under agents/github-bob/mcp/
  image_example: 192.168.11.170:5000/mcp-servicenow:v2.2.1
---

# ServiceNow Change Control

Complete change control workflow via ServiceNow MCP v2.2.1 with 33 tools.

## What Changed in v2.2.1

**New:**
- **snow_change_submit** ⭐ — Single entry point for CAB submission (replaces split workflow). Works for both:
  - **New change + submit** — Pass the same fields as express (at least `short_description`). With `submit_for_cab` default `true`, creates the CHG, validates readiness (100%), and moves to Assess state (CAB review). If planning/window is incomplete, returns `submitted_for_cab: false` with missing field list.
  - **Existing change only** — Pass `number` or `sys_id` (no `short_description`). Validates readiness and sets Assess (same as `snow_change_request_approval`).
  - Accepts `camelCase` (`submitForCab`) and `snake_case` (`submit_for_cab`).
  - Refactored to share `executeChangeExpress()` logic so create behavior stays in sync with `snow_change_express`.

## What Changed in v2.2.0

**Fixed:**
- **camelCase parameter support** — The server now accepts both `camelCase` (implementationPlan, shortDescription, etc.) and `snake_case` parameters. Previously only snake_case was read, so planning fields were silently dropped.
- **Falsy-check brittleness** — Now uses `hasContent()` helper; only empty strings are skipped (not `false`, `0`, etc.).
- **ServiceNow POST quirk** — Long planning fields are often not fully applied on `POST`. The server now automatically `PATCH`es the same fields immediately after create, then re-fetches to compute accurate readiness.
- **Express with minimal fields** — `fill_default_planning` defaults to `true`: if justification/implementation/backout/test are missing, the server generates them from `short_description` + `description`. Opt out with `fill_default_planning: false`.

**New:**
- **snow_change_prepare_for_review** — Low-token path for existing CHGs: builds all four planning fields from a single `change_summary` (or from the record's current description), optionally sets maintenance window, and auto-submits for approval when readiness hits 100%. Ideal for Birdman-style "paste audit paragraph once" flows.

## When to Use

- Creating change requests (CHG tickets) for infrastructure changes
- Managing change lifecycle from Planning → Schedule → Approval → Implement → Review
- Checking change readiness and missing required fields
- Phoenix Project-style governance: prove controlled flow without blocking it

## Tool Categories

### Express Tools (1-call, token-efficient)

**snow_change_submit** ⭐ RECOMMENDED — Single entry point for CAB submission (new or existing CHG):

**New change + submit:**
```bash
mcp-call servicenow snow_change_submit '{
  "short_description": "Deploy mcp-servicenow v2.2.1",
  "justification": "Add snow_change_submit tool for unified CAB workflow",
  "implementation_plan": "1. Build image\n2. Push to registry\n3. Update ArgoCD\n4. Restart aggregator",
  "backout_plan": "Revert ArgoCD to v2.2.0, restart aggregator",
  "test_plan": "Verify snow_change_submit appears in tool list",
  "planned_start_date": "2026-03-30 02:00:00",
  "planned_end_date": "2026-03-30 04:00:00",
  "submit_for_cab": true
}'
```
- Creates CHG, validates readiness (100%), and moves to Assess state (CAB review) when `submit_for_cab: true` (default).
- Returns `submitted_for_cab: true` if successful, or `false` with `missing_fields` list if incomplete.
- Accepts all `snow_change_express` fields (including `fill_default_planning` for auto-generated planning text).

**Existing change only (validate + submit):**
```bash
mcp-call servicenow snow_change_submit '{
  "number": "CHG0030012",
  "submit_for_cab": true
}'
```
- Validates readiness and sets Assess (same as `snow_change_request_approval`).
- Pass `number` or `sys_id` (no `short_description` required).

**snow_change_prepare_for_review** — Best for existing CHGs; fill planning + window in one call:
```bash
mcp-call servicenow snow_change_prepare_for_review '{
  "number": "CHG0030011",
  "change_summary": "Paste the audit paragraph once here.",
  "planned_start": "2026-03-30 02:00:00",
  "planned_end": "2026-03-30 04:00:00",
  "submit_for_approval": true
}'
```
- Builds all four planning fields (justification, implementation_plan, backout_plan, test_plan) from `change_summary` (or from the record's current `description` + `short_description` if summary is omitted).
- Optional `planned_start` / `planned_end` (accepts ServiceNow datetime format or aliases like `start_date`, `end_date`, `planned_start_date`, `planned_end_date`).
- `submit_for_approval` defaults to `true`: auto-advances to Assess when readiness is 100%; otherwise returns missing field list.
- Returns: `number`, `planning_populated`, `missing_fields`, `state`, `readiness_score`.
- Use `snow_change_status` afterward to confirm 100% readiness.

**snow_change_express** — Create fully-formed CHG with all tabs populated in one call:
**snow_change_express** — Create fully-formed CHG with all tabs populated in one call:
```bash
mcp-call servicenow snow_change_express '{
  "short_description": "Add firewall rule to PA-850-EDGE-01",
  "justification": "Allow access from 10.1.2.0/24 to internal services",
  "implementation_plan": "1. Review current ruleset\n2. Add new rule via GUI\n3. Commit and verify",
  "backout_plan": "Remove rule via GUI, commit changes",
  "test_plan": "Verify traffic flows from 10.1.2.0/24, test rollback",
  "planned_start_date": "2026-04-01 10:00:00",
  "planned_end_date": "2026-04-01 11:00:00",
  "affected_cis": ["pa850_sys_id"],
  "priority": 3,
  "risk": 3,
  "impact": 3
}'
```
- Accepts both `camelCase` (implementationPlan, shortDescription, etc.) and `snake_case` parameters.
- `fill_default_planning` defaults to `true`: if planning fields are missing, the server generates them from `short_description` + `description`. Set `fill_default_planning: false` to disable.
- Server auto-PATCH after POST to work around ServiceNow's long-field quirk, then re-fetches for accurate readiness.
- Returns: change_number, sys_id, readiness_score, warnings, state

**snow_change_close** — Close CHG with review status:
```bash
mcp-call servicenow snow_change_close '{
  "change_number": "CHG0030009",
  "review_status": "successful",
  "close_notes": "Rule added successfully, verified traffic flow"
}'
```

### Phase Tools (granular per-tab)

**snow_change_plan** — Update Planning tab:
```bash
mcp-call servicenow snow_change_plan '{
  "change_number": "CHG0030009",
  "justification": "Business requirement for new application",
  "implementation_plan": "Step-by-step procedure...",
  "backout_plan": "Rollback procedure...",
  "test_plan": "Validation steps..."
}'
```

**snow_change_schedule** — Update Schedule tab:
```bash
mcp-call servicenow snow_change_schedule '{
  "change_number": "CHG0030009",
  "planned_start_date": "2026-04-01 10:00:00",
  "planned_end_date": "2026-04-01 11:00:00",
  "cab_date": "2026-03-28 14:00:00",
  "cab_delegate": "john.smith"
}'
```

**snow_change_check_conflicts** — Detect scheduling overlaps:
```bash
mcp-call servicenow snow_change_check_conflicts '{
  "change_number": "CHG0030009"
}'
```
Returns: list of conflicting changes with time windows

**snow_change_add_note** — Append work notes or comments:
```bash
mcp-call servicenow snow_change_add_note '{
  "change_number": "CHG0030009",
  "work_notes": "Pre-change validation completed",
  "comments": ""
}'
```

**snow_change_add_task** — Create CTASK linked to parent:
```bash
mcp-call servicenow snow_change_add_task '{
  "change_number": "CHG0030009",
  "short_description": "Notify application team",
  "description": "Send notification 24h before change window",
  "assigned_to": "ops-team"
}'
```

**snow_change_attach_ci** — Attach affected CIs:
```bash
mcp-call servicenow snow_change_attach_ci '{
  "change_number": "CHG0030009",
  "ci_sys_id": "pa850_sys_id",
  "task_type": "affected"
}'
```

**snow_change_request_approval** — Submit to Assess (validates required fields):
```bash
mcp-call servicenow snow_change_request_approval '{
  "change_number": "CHG0030009"
}'
```
**Blocks submission** if planning fields (justification, implementation_plan, backout_plan, test_plan, scheduled dates) are empty.

**snow_change_implement** — Advance to Implement state:
```bash
mcp-call servicenow snow_change_implement '{
  "change_number": "CHG0030009"
}'
```

**snow_change_review** — Post-implementation review:
```bash
mcp-call servicenow snow_change_review '{
  "change_number": "CHG0030009",
  "review_status": "successful",
  "review_comments": "All objectives met, no issues",
  "close_code": "successful"
}'
```

### Status Tool (token-efficient summary)

**snow_change_status** — Compact summary across all tabs:
```bash
mcp-call servicenow snow_change_status '{
  "change_number": "CHG0030009"
}'
```
Returns:
- Readiness percentage (0-100%)
- Missing field checklist
- Current state/phase
- Scheduled dates
- Affected CIs count
- Approval status
- Warnings

Example output for incomplete CHG0030009:
```
Readiness: 0%
Missing fields:
  ✗ justification
  ✗ implementation_plan
  ✗ backout_plan
  ✗ test_plan
  ✗ scheduled dates
State: New
```

## Workflows

### Submit Workflow (new CHG, 1 call) ⭐ RECOMMENDED

Best for: new changes with all details known upfront; single call creates + submits to CAB

```bash
# Create + submit for CAB approval in one call
mcp-call servicenow snow_change_submit '{
  "short_description": "Deploy mcp-servicenow v2.2.1",
  "justification": "Add snow_change_submit tool",
  "implementation_plan": "1. Build\n2. Push\n3. Update ArgoCD\n4. Restart aggregator",
  "backout_plan": "Revert to v2.2.0",
  "test_plan": "Verify tool list shows 33 tools",
  "planned_start_date": "2026-03-30 02:00:00",
  "planned_end_date": "2026-03-30 04:00:00",
  "submit_for_cab": true
}'
# Returns: change_number, sys_id, submitted_for_cab (true/false), missing_fields (if any)

# Implement (after CAB approval)
mcp-call servicenow snow_change_implement '{"change_number":"CHG00..."}'

# Close
mcp-call servicenow snow_change_close '{
  "change_number":"CHG00...",
  "review_status":"successful"
}'
```

### Prepare-for-Review Workflow (existing CHG, 1-2 calls)

Best for: CHGs already created (e.g. via phased workflow); need to fill planning + window in one step

```bash
# 1. Fill planning + window + auto-submit
mcp-call servicenow snow_change_prepare_for_review '{
  "number": "CHG0030011",
  "change_summary": "Deploy mcp-servicenow v2.2.0 with camelCase fix and prepare-for-review tool. Update aggregator config and restart.",
  "planned_start": "2026-03-30 02:00:00",
  "planned_end": "2026-03-30 04:00:00",
  "submit_for_approval": true
}'

# 2. Verify readiness
mcp-call servicenow snow_change_status '{"change_number":"CHG0030011"}'

# 3. Implement (after CAB approval)
mcp-call servicenow snow_change_implement '{"change_number":"CHG0030011"}'

# 4. Close
mcp-call servicenow snow_change_close '{
  "change_number":"CHG0030011",
  "review_status":"successful"
}'
```

### Express Workflow (create only, no submit)

Best for: when you need to review/edit before submitting to CAB

```bash
# 1. Create fully-formed change (does NOT submit)
mcp-call servicenow snow_change_express '{...all fields...}'

# 2. (optional) Edit planning/schedule via snow_change_plan / snow_change_schedule

# 3. Submit to CAB when ready
mcp-call servicenow snow_change_submit '{"number":"CHG00...","submit_for_cab":true}'

# 4. Implement
mcp-call servicenow snow_change_implement '{"change_number":"CHG00..."}'

# 5. Close
mcp-call servicenow snow_change_close '{
  "change_number":"CHG00...",
  "review_status":"successful"
}'
```

### Phased Workflow (step-by-step)

Best for: complex changes built incrementally

```bash
# 1. Create minimal change
mcp-call servicenow snow_create_change '{
  "short_description":"...",
  "type":"normal",
  "priority":3
}'

# 2. Add planning details
mcp-call servicenow snow_change_plan '{
  "change_number":"CHG00...",
  "justification":"...",
  "implementation_plan":"...",
  "backout_plan":"...",
  "test_plan":"..."
}'

# 3. Schedule
mcp-call servicenow snow_change_schedule '{
  "change_number":"CHG00...",
  "planned_start_date":"...",
  "planned_end_date":"..."
}'

# 4. Check readiness
mcp-call servicenow snow_change_status '{"change_number":"CHG00..."}'

# 5. Attach CIs
mcp-call servicenow snow_change_attach_ci '{
  "change_number":"CHG00...",
  "ci_sys_id":"..."
}'

# 6. Check conflicts
mcp-call servicenow snow_change_check_conflicts '{"change_number":"CHG00..."}'

# 7. Submit to CAB (validates all required fields, moves to Assess)
mcp-call servicenow snow_change_submit '{"number":"CHG00...","submit_for_cab":true}'

# 8. Implement (after CAB approval)
mcp-call servicenow snow_change_implement '{"change_number":"CHG00..."}'

# 9. Review & close
mcp-call servicenow snow_change_review '{
  "change_number":"CHG00...",
  "review_status":"successful",
  "close_code":"successful"
}'
```

## Server-Side Validation

The ServiceNow MCP enforces CAB requirements:

1. **snow_change_submit** — Validates readiness before moving to Assess (CAB review):
   - Planning fields (justification, implementation_plan, backout_plan, test_plan)
   - Scheduled dates (planned_start_date, planned_end_date)
   - Returns `submitted_for_cab: false` with `missing_fields` list if incomplete

2. **snow_change_request_approval** — Same validation (legacy path, prefer `snow_change_submit`)

3. **snow_change_express** — Returns readiness score (0-100%) and warnings for missing fields (does NOT submit)

4. **snow_change_close** — Validates review_status is set

## Guidance for Birdman (snow-birdman)

**When to use submit:** ⭐ RECOMMENDED (v2.2.1+)
- **New CHG + CAB submission in one call** — pass all planning fields + window, set `submit_for_cab: true` (default)
- **Existing CHG validation + submit** — pass only `number` or `sys_id`, validates readiness and moves to Assess
- Replaces split workflow (express → request_approval); single obvious tool for agents

**When to use prepare-for-review:**
- Existing CHG (from phased workflow or earlier session)
- Need to fill planning + window in one token-efficient call
- "Paste audit paragraph once" flows (auto-generates planning from `change_summary`)
- Auto-submit when 100% ready

**When to use express:**
- Create CHG without submitting (review/edit before CAB)
- Need readiness score + warnings before submission

**When to use phased:**
- Complex changes requiring coordination
- Changes built incrementally (CI attachment, task creation)
- Collaborative planning across sessions

**Always:**
- Call `snow_change_status` after any create/update to confirm 100% readiness before claiming "ready for CAB"
- Store CHG number + sys_id in Archivist (namespace: change-control)
- Link CHG to related work (MCP builds, K8s deploys, firewall changes)
- Use normal change type unless emergency

**Parameter flexibility:**
- Both `camelCase` and `snake_case` work — server accepts `implementationPlan` or `implementation_plan`, `shortDescription` or `short_description`, `submitForCab` or `submit_for_cab`, etc.
- `snow_change_prepare_for_review` accepts `planned_start` / `planned_end` (or aliases like `start_date`, `end_date`, `planned_start_date`, `planned_end_date`).

## Verification Example

CHG0030009 ("Add firewall rule to PA-850-EDGE-01") created in earlier test:
- Status tool shows: **0% readiness**, 5 missing planning fields
- Matches ServiceNow UI exactly
- request_approval would block until fields populated

**CHG0030011 — v2.2.0 testing:**
- `snow_change_prepare_for_review` filled all planning fields from a single `change_summary` paragraph
- Auto-PATCH after POST ensured long fields persisted
- `snow_change_status` confirmed 100% readiness
- Auto-submitted to Assess state

**CHG0030012 — v2.2.1 testing:**
- `snow_change_submit` created new CHG + submitted to CAB in one call
- Returns `submitted_for_cab: true` when readiness is 100%
- Unified workflow replaces split express → request_approval path

## All 33 Tools

**Existing (19):**
snow_list_incidents, snow_get_incident, snow_create_incident, snow_update_incident, snow_list_changes, snow_get_change, snow_create_change, snow_update_change, snow_list_problems, snow_create_problem, snow_list_cis, snow_get_ci, snow_query_table, snow_get_record, snow_create_record, snow_update_record, snow_search_kb, snow_get_user, snow_list_groups

**New Change Lifecycle (14):**
snow_change_express, snow_change_close, snow_change_plan, snow_change_schedule, snow_change_check_conflicts, snow_change_add_note, snow_change_add_task, snow_change_attach_ci, snow_change_request_approval, snow_change_implement, snow_change_review, snow_change_status, snow_change_prepare_for_review, **snow_change_submit** ⭐

## MCP Connection

ServiceNow MCP v2.2.1 available via aggregator:
```bash
# List all 33 tools
mcp-call servicenow --list

# Direct aggregator URL (for Cursor)
http://192.168.11.160:8080/snow/mcp
```

Pod: mcp-servicenow.mcp-servicenow
Image: 192.168.11.170:5000/mcp-servicenow:v2.2.1
Canonical source: apps/mcp-snow/server/ (index.js, Dockerfile, package.json)

## Known Issues

**GitLab mirror sync:** Push to `gitlab.ibhacked.us/mcp/servicenow` currently fails (Vault `admin_token` returns 401 against GitLab API — expired or wrong scope). When the PAT is fixed, sync from `apps/mcp-snow/server/` so CI matches deployed version.
