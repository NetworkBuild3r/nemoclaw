# MCP server reference implementations (this repo)

Python sources under **`mcp-servers/`** are the **public, challenge-facing** implementations for:

| Directory | Role |
|-----------|------|
| **`paloalto/`** | PAN-OS read-oriented MCP (SSE-friendly for cluster aggregator) |
| **`servicenow/`** | ServiceNow MCP (incidents + change control tools) |
| **`brave-search/`** | Brave Search MCP (often run locally with `BRAVE_API_KEY`) |

Build, image, and **GitLab CI/CD** for production forks may live in **separate GitLab repositories** — do **not** copy those trees into this monorepo under `agents/github-bob/mcp/` (that path is **gitignored** on purpose).

**Deploy manifests** for Kubernetes live under [`deploy/k8s/`](../deploy/k8s/) (e.g. `paloalto-mcp/`, `servicenow-mcp/`). Wire URLs in **`config/mcporter.json`** (local, gitignored) from [`config/mcporter.json.example`](../config/mcporter.json.example).
