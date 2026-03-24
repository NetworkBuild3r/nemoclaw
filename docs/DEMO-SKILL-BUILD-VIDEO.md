# Demo: Chief → skill-builder → skill on disk (video-friendly)

This stack uses OpenClaw **`sessions_spawn`**, which is **always non-blocking**. Chief must **not** say “done” on spawn — see **`agents/chief/AGENTS.md`** (“Reporting on delegated work”). This doc is for **recording** and **pre-flight checks**.

## Flow (two Chief turns)

```
You:     "Build me a Cisco IOS CLI skill"
           │
Chief T1:  sessions_spawn → { status: "accepted" }
           Reply: "Dispatched skill-builder — working. I'll report when they deliver."
           │
           [subagent runs: often 2–15+ minutes]
           [skill-builder: openclaw-skills/… + archivist_store skill-engineering]
           │
Chief T2:  announce arrives OR you verify Archivist
           Reply: paths, summary, follow-ups
```

## Copy-paste: `sessions_spawn` task (Cisco IOS CLI example)

Use with **`agentId: "skill-builder"`**, **`runTimeoutSeconds`: 900** (or higher), **`sandbox: "inherit"`**. Adjust names/paths as needed.

```
Goal: Research Cisco IOS CLI patterns and ship a fleet-visible OpenClaw AgentSkill.

Steps:
1. Research IOS CLI command families (show / configure / interface / troubleshooting) from public docs; keep notes concise.
2. Create openclaw-skills/cisco-ios-cli/SKILL.md (folder name = frontmatter name: cisco-ios-cli) following author-skills-secure shape: Goal, When to Use, Instructions, Scripts & References, Security.
3. Include safety rules (e.g. never destructive defaults like write erase without explicit human confirmation).
4. From repo root: ln -sfn ../../openclaw-skills/cisco-ios-cli .cursor/skills/cisco-ios-cli
5. BEFORE finishing: mcp-call archivist archivist_store with agent_id skill-builder, namespace skill-engineering, text listing absolute paths to SKILL.md and symlink, tags ["skill","shipped","cisco-ios"].
6. archivist_session_end if your session supports it for skill-builder.
7. If you cannot write the repo, archivist_store the full SKILL.md draft into skill-engineering with tags draft-only or blocked-write — do not exit silently.

Done when: openclaw-skills/cisco-ios-cli/SKILL.md exists and skill-engineering contains a store with those paths (or explicit blocked draft).
```

## Video edit (short runtime)

**Option A — time-lapse (recommended)**  
Show Chief T1 → cut with on-screen “⏱ N min later” → show Archivist or announce → Chief T2 → open `SKILL.md` in the editor.

**Option B — two takes**  
Record request + final result separately; splice with a transition.

## While waiting (b-roll)

- **Archivist:** watch `skill-engineering` / `chief` stores (dashboard or `mcp-call archivist archivist_search` from a shell).
- **OpenClaw:** if your build exposes **`/subagents list`** / **`/subagents log`**, use them as b-roll — availability depends on OpenClaw version; omit if not present.

## Pre-record checklist

| Step | Pass? |
|------|--------|
| Chief **`sessions_spawn`** to **skill-builder** returns **accepted** | |
| Chief T1 wording = **delegated**, not **done** | |
| **skill-builder** can **`mcp-call archivist`** from its context | |
| **`openclaw-skills/<name>/SKILL.md`** exists after run | |
| **`skill-engineering`** has a store with paths or explicit **draft/blocked** | |
| Chief T2 (announce or Archivist poll) summarizes **paths** | |
| Gateway restarted after **`openclaw.json`** / bootstrap changes | |

## Related

- [`docs/OPENCLAW-SKILLS.md`](OPENCLAW-SKILLS.md) — where skills live  
- [`openclaw-skills/nemoclaw-skill-builder/references/REFERENCE.md`](../openclaw-skills/nemoclaw-skill-builder/references/REFERENCE.md) — fleet visibility pitfalls
