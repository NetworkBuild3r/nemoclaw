# NemoClaw challenge — Enterprise DevOps agent fleet + shared memory

**AHEAD × NVIDIA NemoClaw (deadline Mar 31, 2026)** — secure, always-on **OpenClaw** agents (Telegram) with **policy guardrails**, **LiteLLM → Bedrock**, and **NVIDIA** inference/embeddings where configured.

Use **`/home/bnelson/nemoclaw`** (this repo) as the single place for NemoClaw / OpenClaw / **Archivist** / LiteLLM operations.

---

## Archivist — the “memory” differentiator

This demo’s key integration is **Archivist**: recursive long-term memory, Qdrant + SQLite graph, **MCP** tools, **RBAC** namespaces, and fleet-wide search.

| Read this | Why |
|-----------|-----|
| **[`archivist-oss/README.md`](archivist-oss/README.md)** | Full product explanation: features, architecture diagram, quick start, MCP URL, health checks. **Start here** to understand what Archivist does. |
| **[`docs/ARCHIVIST.md`](docs/ARCHIVIST.md)** | How Archivist is wired into *this* repo (compose overrides, agents, upstream lineage). |

**Docker (from repo):**

```bash
cd archivist-oss
docker compose -f docker-compose.yml -f ../stack/docker-compose.override.yml --env-file ../stack/.env up -d
```

See [`stack/README.md`](stack/README.md) for LiteLLM + env file notes.

---

## Repo layout

| Path | Purpose |
|------|---------|
| `archivist-oss/` | **Archivist + Qdrant** service (Python MCP server) — **included in full for GitHub** |
| `agents/` | GitOps agent workspaces (Chief, GitBob, Argo, Kate, Greg) |
| `openclaw-skills/` | **OpenClaw runtime** AgentSkills (`SKILL.md` trees); loaded via `skills.load.extraDirs` in `openclaw.json`. See skill **`nemoclaw-skill-builder`** for how to add skills. |
| `.cursor/skills/` | Symlinks into `openclaw-skills/` for **Cursor** only (same content) |
| `stack/` | LiteLLM config (example + local gitignored), `docker-compose.override.yml`, stack `.env` |
| `config/`, `policies/`, `prompts/`, `sample-memories/` | Challenge config and seed memories |
| `docs/` | Vault docs, submission checklist, Archivist bridge doc |
| `vendor/NemoClaw/` | **Not in git** (large) — `git clone https://github.com/NVIDIA/NemoClaw` beside this repo |
| `scripts/` | Vault → disk sync for Telegram tokens and AWS Bedrock env |
| `.openclaw/` | OpenClaw state (gitignored; `~/.openclaw` may symlink here) |
| `.config/openclaw/` | `vault.env` + generated `aws-bedrock.env` (gitignored) |

---

## Symlinks (optional, on your ROC host)

| Path | → |
|------|----|
| `~/.openclaw` | `nemoclaw/.openclaw/` |
| `~/.config/openclaw` | `nemoclaw/.config/openclaw/` |
| `~/nemoclaw-challenge` | `nemoclaw/` |
| `~/docs/reference` | `nemoclaw/docs/reference/` |

---

## GitHub / submission

- **[`docs/GITHUB-SUBMISSION.md`](docs/GITHUB-SUBMISSION.md)** — checklist (slide, <5 min video, public repo, no secrets).

### Demo recording

| Shot | What to show | Source |
|------|-------------|--------|
| 1. NemoClaw sandbox | `nemoclaw openclaw status` — policies, model, sandbox phase | Terminal |
| 2. Blocked egress | `curl` to a forbidden host → OpenShell deny in logs | Terminal + `openshell` |
| 3. Task delegation | `ahead-chief` stores task brief in Archivist `tasks` | `mcp-call archivist archivist_store` |
| 4. Build + push | `docker build` / `docker push` paloalto-mcp image | Terminal |
| 5. Deploy + smoke | `kubectl apply` → `mcp-call paloalto panos_show_system_info` | Terminal + MCP |
| 6. Archivist proof | `mcp-builder` stores evidence in `mcp-engineering` | `mcp-call archivist` |
| 7. Firewall audit | `palo-expert` calls PAN-OS tools, stores in `firewall-ops` | `mcp-call paloalto` + Archivist |
| 8. Cross-team synthesis | `ahead-chief` → `archivist_insights` merges all namespaces | `mcp-call archivist` |
| 9. Chief spawn (optional) | Chief via Telegram → `sessions_spawn` → skill-builder | Telegram + gateway log |

See [`docs/AHEAD-DEMO-RUNBOOK.md`](docs/AHEAD-DEMO-RUNBOOK.md) for the full runbook and [`docs/DEMO-SKILL-BUILD-VIDEO.md`](docs/DEMO-SKILL-BUILD-VIDEO.md) for the Chief two-turn spawn flow.
- **Secrets:** never commit `stack/litellm-config.yaml` (use `stack/litellm-config.yaml.example`), `.openclaw/`, or `.config/openclaw/` secrets.

**License:** [`LICENSE`](LICENSE) (Apache-2.0); components like `archivist-oss/` retain their own `LICENSE` where present.

---

## Upstream

- **NemoClaw:** [github.com/NVIDIA/NemoClaw](https://github.com/NVIDIA/NemoClaw)
- **Archivist (lineage):** [github.com/NetworkBuild3r/archivist-oss](https://github.com/NetworkBuild3r/archivist-oss)
