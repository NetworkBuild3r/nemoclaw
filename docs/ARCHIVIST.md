# Archivist in this demo

**Archivist** is the **shared long-term memory** service for the agent fleet: vector search (Qdrant), a temporal knowledge graph (SQLite), RBAC namespaces, and an MCP server for tools like `archivist_search`.

Everything you need to understand behavior, APIs, and architecture is in the upstream-style docs **inside this repo**:

→ **[`archivist-oss/README.md`](../archivist-oss/README.md)** — features, quick start, architecture diagram, MCP endpoint.

### How it connects here

- **Docker:** base compose in `archivist-oss/docker-compose.yml`, ROC overrides in [`stack/docker-compose.override.yml`](../stack/docker-compose.override.yml) (paths relative to `stack/`).
- **Agents:** OpenClaw GitOps workspaces under `agents/` call Archivist via MCP per your `config/` and NemoClaw policies.
- **Upstream lineage:** originally from [`NetworkBuild3r/archivist-oss`](https://github.com/NetworkBuild3r/archivist-oss); this tree includes **local patches** for the challenge demo.
