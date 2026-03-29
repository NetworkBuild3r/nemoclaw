# GitHub submission checklist (AHEAD × NVIDIA NemoClaw Challenge)

**Deadline:** March 31, 2026 · **Contact:** eric.kaplan@ahead.com

## Challenge deliverables (you ship these)

| # | Deliverable | Notes |
|---|-------------|--------|
| 1 | **One slide** | Value prop + architecture — not stored in this repo |
| 2 | **Demo video** | &lt; 5 minutes, show the real system — host on Drive/YouTube, link in email |
| 3 | **Public GitHub repo** | This tree (or a fork) with **no secrets** |

## Pre-push verification (automated)

From repo root:

```bash
chmod +x scripts/verify-public-push.sh   # once
./scripts/verify-public-push.sh
```

Fix anything it reports, then commit. **`origin` is GitHub only** (no GitLab push target for this monorepo):

```bash
git remote -v   # expect: origin  git@github.com:NetworkBuild3r/nemoclaw-challenge.git
git push -u origin main
```

If the repo name on GitHub differs, run: `git remote set-url origin git@github.com:YOUR_ORG/YOUR_REPO.git`

## Repo readiness (maintain this before `git push`)

- [ ] **`git init`** (or clone) and first commit only after secrets are scrubbed.
- [ ] **`./scripts/verify-public-push.sh`** passes.
- [ ] **`agents/github-bob/home_k3`** is **not** in the git index (private GitOps clone — `.gitignore`d; remove with `git rm --cached agents/github-bob/home_k3` if it was ever committed as a gitlink).
- [ ] **`stack/litellm-config.yaml`** is **gitignored**; only **`stack/litellm-config.yaml.example`** is tracked. Real config stays local.
- [ ] **`.openclaw/`** and **`.config/openclaw/`** stay gitignored (tokens, `openclaw.json` may contain API keys in `skills` — never force-add).
- [ ] **`stack/.env`** — no secrets in tracked files; use Vault docs in `docs/vault-*.md`.
- [ ] **Rotate** any key that was ever pasted into a tracked file, chat, or screenshot.
- [ ] Root **`README.md`**: what you built, enterprise use case, how to run (high level), link to upstream **github.com/NVIDIA/NemoClaw**.
- [ ] **`LICENSE`** at repo root (e.g. Apache-2.0 or MIT — match your employer policy).

## What reviewers should see

- **NemoClaw / OpenClaw** as the backbone (agents, policies, gateway).
- **Enterprise story** (e.g. DevOps / GitOps fleet + shared memory) — your `agents/`, `docs/`, Archivist integration.
- **Ecosystem**: NVIDIA (Nemotron, embeddings, Bedrock via LiteLLM) + optional partner — describe in README, redact IPs if needed.
- **Architecture diagram (Draw.io):** [`docs/diagrams/nemoclaw-fleet-architecture.drawio`](diagrams/nemoclaw-fleet-architecture.drawio) — open in [diagrams.net](https://app.diagrams.net); aligns with the design narrative below.

## Design narrative (full story — architecture, not feature list)

Use this block for your **one slide** and **demo voiceover**. It emphasizes **design choices** and **why** they matter for an enterprise / AHEAD-style product, not every integration you turned on.

### Multi-agent fleet and shared memory (RBAC)

We designed a **multi-agent fleet** with a **shared memory system** (**Archivist-OSS**) so coordination survives sessions and specialists do not each rebuild context from scratch. Memory is not a flat blob: it is **partitioned by role** using **namespaces and agent identity (RBAC-aligned memory)** — the same pattern you would want in **AHEAD product lines** where **who may read or write what** is as important as **what was stored**. The chief-of-staff pattern gives **one human entry point** while **execution and memory writes** stay on the **right specialist**.

### MCP as the scalable boundary to the outside world

Outside connectivity (Git platforms, Kubernetes, Argo CD, observability, ServiceNow, firewalls, search) is not exposed as “the model may curl anything.” We treat **MCP** as the **controlled surface**: **named tools**, **typed operations**, and **servers that hold credentials** — so the agent’s job is to **choose tools and arguments**, not to **invent ad-hoc integration code** or **handle raw secrets**. That scales operationally: new systems become **new MCP servers and routes**, not **new prompt hacks per agent**.

### Token efficiency and operational maturity

Because **capabilities are tools** (e.g. **create or update a change ticket**, **inspect cluster state**, **troubleshoot Palo Alto policy**), the model spends **fewer tokens** on **re-deriving procedures** and **one-off shell logic**. The **durable logic** lives in **MCP implementations** (scripts, API clients, validations) that teams can **test and version** like any other service — the agent orchestrates; **the platform executes**.

### MCP aggregator on Kubernetes

An **MCP aggregator** in the **Kubernetes cluster** provides a **single, cluster-scoped front door** to those backends: **routing**, **operational ownership**, and **defense in depth** (e.g. **network policies** so only the aggregator talks to sensitive MCP workloads) live **next to the services**, not scattered on laptops. Combined with a **central secret store** (e.g. **HashiCorp Vault** → runtime injection), **integration secrets stay out of agent prompts and out of git**; agents see **tool names and results**, not **passwords and API keys**.

### One-sentence summary

**We designed a RBAC-aware shared-memory fleet, bounded external access through MCP and a cluster-hosted aggregator, and pushed durable integration logic into tools — for safer, more token-efficient, enterprise-grade agent operations.**

## What reviewers can see vs your private GitOps repo

Judges only have **this public repo**, your **slide**, and your **demo video**. They will **not** see a separate Kubernetes / Argo CD “apps” repository if you keep it private. That does **not** weaken the story if you split the proof cleanly:

| Artifact | What it proves |
|----------|----------------|
| **This repo** | **Design and code**: agent workspaces, skills, MCP server source, **reference** `deploy/k8s/` manifests (aggregator notes, example MCP deployments), `config/mcporter*.json` **contracts**, Archivist, Vault/docs patterns — i.e. *how* you would build and wire the fleet. |
| **Video** | **End-to-end reality**: live calls through the aggregator, GitOps outcomes, SNOW/Palo flows, whatever you choose to show — i.e. *that* it runs in your environment. |
| **Slide** | **Intent in one glance**: architecture diagram; optional footnote that **production cluster wiring** may live in a **private GitOps repo** (standard for enterprises). |

**Do not imply** judges can click through to your private `home_k3` (or equivalent). **Do** imply that **the pattern** (aggregator in-cluster, MCP backends, policies) is **documented and partially reproduced here**, and the **video is the ground truth** for your lab.

## What’s in the repo

- **`archivist-oss/`** — **fully included** (Python service + tests + docs). The nested upstream `.git` was moved to **`.upstream-archivist-git-backup/`** (gitignored) so your **local patches** ship with the monorepo. Judges should open **[`archivist-oss/README.md`](../archivist-oss/README.md)** for the full story.
- **`vendor/NemoClaw/`** — **excluded** (~1GB). Document `git clone https://github.com/NVIDIA/NemoClaw` next to this repo (see root `README.md`).
