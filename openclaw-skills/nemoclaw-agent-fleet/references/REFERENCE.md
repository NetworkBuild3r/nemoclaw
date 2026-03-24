# Fleet quick reference

## Agent roster (full)

### GitOps & delivery

| Agent id | Persona | MCP focus | Archivist `namespace` |
|----------|---------|-----------|------------------------|
| `chief` | Chief of staff | None (delegates) | `chief` |
| `gitbob` | GitLab/GitHub | `gitlab` | `pipeline` |
| `argo` | Argo CD | `argocd` | `deployer` |
| `kubekate` | Kubernetes | `kubernetes` | `deployer` |
| `grafgreg` | Grafana | `grafana` | `pipeline` |

### Palo Alto, skills, and capability building

| Agent id | Persona | MCP focus | Archivist `namespace` |
|----------|---------|-----------|------------------------|
| `ahead-chief` | Task bus orchestrator | None (Archivist only) | `tasks` |
| `palo-expert` | PAN-OS / firewall | `paloalto` | `firewall-ops` |
| `mcp-builder` | Build/deploy MCP servers | None (builds them) | `mcp-engineering` |
| `skill-builder` | Author AgentSkills | None (writes SKILL.md) | `skill-engineering` |
| `researcher` | Doc/API research | None (reads docs) | `skills-research` |
| `skill-author` | Skill authoring (alternate) | None | `skill-engineering` |

## Delegation mechanisms

| Method | Mechanism | Who uses it | Blocking? |
|--------|-----------|-------------|-----------|
| `sessions_spawn` | OpenClaw tool — isolated one-shot child session | Chief, ahead-chief | **No** — returns immediately |
| Normal OpenClaw routing | Gateway routes message to agent by `agentId` | Any user/bot | Synchronous chat |
| Archivist `tasks` namespace | Write brief, builder polls and picks up | ahead-chief → skill-builder, mcp-builder | Async (polling) |

## `sessions_spawn` API reference

**NemoClaw does not implement subagents.** Spawning is an **OpenClaw** feature. NemoClaw only provides sandbox/security.

### Call signature

```
sessions_spawn({
  task: string,          // Rich goal description (goal, constraints, done-when)
  agentId?: string,      // Target registered agent (e.g. "skill-builder")
  label?: string,        // Human-readable label for the run
  runTimeoutSeconds?: number,  // Kill after this many seconds (default: none)
  sandbox?: string       // "inherit" to reuse parent sandbox under NemoClaw
})
```

### Return value (immediate, non-blocking)

```json
{
  "status": "accepted",
  "runId": "<unique-run-id>",
  "childSessionKey": "<session-key>"
}
```

**`accepted` does NOT mean finished.** The child session starts asynchronously. Results arrive later via OpenClaw `announce` (best-effort, lost on gateway restart) or durable `archivist_store` by the child.

### What the child session receives

- Auto-injected: **`AGENTS.md`** + **`TOOLS.md`** from the target agent's workspace directory.
- NOT injected: SOUL.md, IDENTITY.md, HEARTBEAT.md — put critical context in the `task` string.

### Recommended patterns

| Scenario | Guidance |
|----------|----------|
| Skill authoring | `runTimeoutSeconds >= 900` (15+ min); `task` includes done-when paths |
| Quick research | `runTimeoutSeconds: 300-600` |
| Always | Instruct child to `archivist_store` + `archivist_session_end` before relying on announce |
| After spawn | Tell user you **delegated**, not that it's **done** |
| After announce/timeout | `archivist_search` with child's `agent_id` + namespace to confirm delivery |

### Example — spawn skill-builder

```
sessions_spawn({
  task: "Goal: draft openclaw-skills/pan-example/SKILL.md for PAN-OS rule reads. Constraints: follow nemoclaw-skill-builder format. Done when: SKILL.md exists, symlink created at .cursor/skills/pan-example, archivist_store into skill-engineering with file paths.",
  agentId: "skill-builder",
  label: "PAN skill draft",
  runTimeoutSeconds: 900,
  sandbox: "inherit"
})
```

### Example — spawn researcher

```
sessions_spawn({
  task: "Goal: research Cisco IOS XE REST API auth and endpoints. Done when: archivist_store into skills-research with structured notes (auth method, base URL pattern, key endpoints, rate limits).",
  agentId: "researcher",
  label: "Cisco IOS research",
  runTimeoutSeconds: 600,
  sandbox: "inherit"
})
```

### Human equivalent

Users can also spawn via slash command: `/subagents spawn skill-builder "task description"` — same semantics.
