---
name: nemoclaw-overview
description: Navigate the NemoClaw demo repo (Archivist, LiteLLM stack, OpenClaw agents, docs, scripts). Use when starting work in nemoclaw, explaining repo layout, or finding where Docker, Vault, or MCP config lives.
metadata: {"openclaw":{"always":true}}
---

# Goal

Give agents and humans a reliable mental map of the **nemoclaw** repository: what each top-level directory is for and where to read next.

## When to Use

- Onboarding or “where does X live?” questions for this repo.
- Running Archivist + Qdrant locally or understanding the challenge layout.
- Finding Vault-related scripts vs OpenClaw state vs application code.

## Instructions

1. **Single home directory:** Treat the repository root as the canonical place for NemoClaw / OpenClaw / Archivist / LiteLLM operations; start from `README.md` at the repo root.
2. **Archivist (memory):** Implementation and upstream-style docs live in `archivist-oss/`. Bridge doc: `docs/ARCHIVIST.md`. Start with `archivist-oss/README.md` for architecture and MCP URL patterns.
3. **Runtime stack:** LiteLLM + compose overrides are under `stack/` (`stack/README.md`, `stack/docker-compose.override.yml`). Real `litellm-config.yaml` is gitignored; use `stack/litellm-config.yaml.example`.
4. **Agents:** Per-agent workspaces under `agents/` (e.g. `gitops-chief`, `github-bob`, `argocd-argo`, `k8s-kate`, `grafana-greg`) with `AGENTS.md`, `SOUL.md`, and optional `TOOLS.md`.
5. **Secrets:** Do not expect API keys in `nemoclaw/.env` (comments only). Project secrets use HashiCorp Vault paths documented in `docs/vault-project-env.md` and `docs/vault-telegram-bots.md`. OpenClaw runtime state is under `.openclaw/` (often gitignored); host env files under `.config/openclaw/` (see `.config/openclaw/README.md`).
6. **MCP client config:** `config/mcporter.json` lists HTTP MCP servers (Kubernetes, Argo CD, Grafana, GitLab, Archivist). Hosts are deployment-specific — see skill `nemoclaw-mcp-fleet`.
7. **Vendor:** `vendor/NemoClaw/` is optional upstream clone (not in git). Document clone URL in repo `README.md` instead of committing the tree.

## Scripts & References

- `{baseDir}/references/REFERENCE.md` — quick command snippets and file pointers.

## Security

- Never commit `.openclaw/openclaw.json` or token files; treat them as local-only. Do not paste gateway tokens or bot tokens into skills or chat logs.
