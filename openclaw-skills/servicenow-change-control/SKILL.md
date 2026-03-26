---
name: servicenow-change-control
description: ServiceNow change control via MCP v2.0.0 — 31 tools for CAB-compliant change lifecycle (express + phased workflows, status checking, server-side validation). Use when creating/managing ServiceNow change tickets for infrastructure changes.
compatibility: OpenClaw agents with servicenow MCP access; Birdman (snow-birdman)
metadata:
  version: 2.0.0
  tools: 31
---

# ServiceNow Change Control

Complete change control workflow via ServiceNow MCP v2.0.0 with 31 tools.

## When to Use

- Creating change requests (CHG tickets) for infrastructure changes
- Managing change lifecycle from Planning → Schedule → Approval → Implement → Review
- Checking change readiness and missing required fields
- Phoenix Project-style governance: prove controlled flow without blocking it

## Tool Categories

### Express Tools (1-call, token-efficient)

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
Returns: change_number, sys_id, readiness_score, warnings, state

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

### Express Workflow (1-2 calls)

Best for: routine changes with all details known upfront

```bash
# 1. Create fully-formed change
mcp-call servicenow snow_change_express '{...all fields...}'

# 2. (if ready) Request approval
mcp-call servicenow snow_change_request_approval '{"change_number":"CHG00..."}'

# 3. Implement
mcp-call servicenow snow_change_implement '{"change_number":"CHG00..."}'

# 4. Close
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

# 7. Request approval (validates all required fields)
mcp-call servicenow snow_change_request_approval '{"change_number":"CHG00..."}'

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

1. **snow_change_request_approval** — Blocks if planning fields empty:
   - justification
   - implementation_plan
   - backout_plan
   - test_plan
   - planned_start_date
   - planned_end_date

2. **snow_change_express** — Returns readiness score (0-100%) and warnings for missing fields

3. **snow_change_close** — Validates review_status is set

## Guidance for Birdman (snow-birdman)

**When to use express:**
- GitOps deployments with known rollback
- Infrastructure changes with documented procedures
- Routine maintenance windows
- All planning details available upfront

**When to use phased:**
- Complex changes requiring coordination
- Changes built incrementally (CI attachment, task creation)
- Need to check readiness before approval
- Collaborative planning across sessions

**Always:**
- Call `snow_change_status` before requesting approval
- Store CHG number + sys_id in Archivist (namespace: change-control)
- Link CHG to related work (MCP builds, K8s deploys, firewall changes)
- Use normal change type unless emergency

## Verification Example

CHG0030009 ("Add firewall rule to PA-850-EDGE-01") created in earlier test:
- Status tool shows: **0% readiness**, 5 missing planning fields
- Matches ServiceNow UI exactly
- request_approval would block until fields populated

## All 31 Tools

**Existing (19):**
snow_list_incidents, snow_get_incident, snow_create_incident, snow_update_incident, snow_list_changes, snow_get_change, snow_create_change, snow_update_change, snow_list_problems, snow_create_problem, snow_list_cis, snow_get_ci, snow_query_table, snow_get_record, snow_create_record, snow_update_record, snow_search_kb, snow_get_user, snow_list_groups

**New Change Lifecycle (12):**
snow_change_express, snow_change_close, snow_change_plan, snow_change_schedule, snow_change_check_conflicts, snow_change_add_note, snow_change_add_task, snow_change_attach_ci, snow_change_request_approval, snow_change_implement, snow_change_review, snow_change_status

## MCP Connection

ServiceNow MCP available via aggregator:
```bash
# List all tools
mcp-call servicenow --list

# Direct aggregator URL (for Cursor)
http://192.168.11.160:8080/snow/mcp
```

Pod: mcp-servicenow.mcp-servicenow
Image: 192.168.11.170:5000/mcp-servicenow:latest
