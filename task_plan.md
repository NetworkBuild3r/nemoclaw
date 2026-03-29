# Task Plan: AHEAD × NemoClaw × Palo Alto (9-day sprint)

## Goal

Ship a judge-ready demo: **memory-as-message-bus** (Archivist), **pre-configured agents** (no spawn), **minimal Palo Alto MCP**, **NemoClaw sandboxes** with OpenShell policy story.

## Phases

### Phase 1: Fleet + RBAC (Days 1–2)

- [x] Extend `config/namespaces.yaml` + `config/team_map.yaml` for demo agents
- [x] Restart Archivist after deploy (see `docs/AHEAD-DEMO-RUNBOOK.md`)
- **Status:** complete

### Phase 2: Agents + MCP skeleton (Days 2–3)

- [x] Workspaces under `agents/{ahead-chief,mcp-builder,researcher,skill-author,palo-expert}/`
- [x] OpenClaw `agents.list` entries (`.openclaw/openclaw.json`)
- [x] `mcp-servers/paloalto` + `deploy/k8s/paloalto-mcp/` + `config/mcporter.json` `paloalto`
- **Status:** complete

### Phase 3: Policies + recording prep (Days 4–6)

- [x] Wire mcp-aggregator route `/paloalto` → paloalto-mcp Service
- [x] Merge `config/policies/ahead_pan_sandbox.preset.yaml` into NemoClaw sandboxes (per runbook matrix); **mcp-builder** needs registry (+ GitLab if CI) egress
- [x] 2–3 dry runs: **`mcp-builder` actually build+pushes** image (or CI), deploys, records proof in `mcp-engineering` — see `docs/AHEAD-DEMO-RUNBOOK.md`
- **Status:** complete

### Phase 4: Video + submit (Days 7–9)

- [x] Record shot list; blocked egress clip
- [x] One slide + README pointer
- **Status:** complete (shot list in README.md; recording is manual)

---

## Phase: NemoClaw + OpenClaw spawn demo (planning + rehearsal)

**Goal:** Document the stack split, tighten Chief spawn UX wording, verify policy egress, smoke the Cisco IOS skill flow, prep recording.

| Step | Description | Status |
|------|-------------|--------|
| 1 | Planning files: `task_plan.md` / `findings.md` / `progress.md` refreshed for this phase | complete |
| 2 | Optional doc tighten: Forbidden-after-spawn in `agents/chief/AGENTS.md` + skill mirror | complete |
| 3 | Policy check: Archivist (+ HTTP docs if needed) in `ahead_pan_sandbox` preset | complete |
| 4 | Smoke: Cisco IOS flow per `docs/DEMO-SKILL-BUILD-VIDEO.md` — log in `progress.md` | complete |
| 5 | Record prep: two-turn UX + b-roll checklist; phase closed | complete |

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Demo agent IDs `ahead-chief`, etc. | Avoid collision with GitOps `chief` namespace |
| `PANOS_MOCK=1` default in k8s | Demo without live firewall |
| Nemotron primary in openclaw.json | NVIDIA rubric; fall back to LiteLLM if key missing |
| Multi-agent demo = OpenClaw `sessions_spawn` + Archivist | NemoClaw only sandboxes/policy/inference; peer A2A not required for clip |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
| | | |

## Chief-only forum Telegram (2026-03-26)

- [x] `openclaw.json`: topics for `-1003828106848` → `chief`; remove other accounts’ `groups` for that id
- [x] Docs + skills (`docs/CHIEF-FORUM-GROUP.md`, `nemoclaw-openclaw-telegram`, example config, vault note, NEMOCLAW stack, deployment skill, chief delegation)
- [ ] Operator: Telegram app — only Chief bot in forum group; BotFather privacy off for Chief

See `findings.md` for technical summary.

## Notes

- Re-read before major decisions.
- Human tracking: `findings.md`, `progress.md`.
