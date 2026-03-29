---
name: gitbob-mcp-deploy
description: GitBob's complete MCP server build and deployment workflow, updated to address ServiceNow integration issues.
---

# GitBob's MCP Deploy Workflow (Updated)

This skill provides the detailed steps for GitBob to build and deploy MCP servers in the NemoClaw fleet, with specific additions to address issues encountered with the ServiceNow MCP integration.

## Critical Additions

### 1. MCP Server Implementation Requirements
- MUST use @modelcontextprotocol/sdk (Node.js) or mcp (Python)
- NEVER commit node_modules (add .gitignore)
- Use ESM modules (package.json: "type": "module") 
- Implement ACTUAL tool functions — no empty stubs
- Example tool structure with real implementations

### 2. Transport Layer (REQUIRED)
- Node.js stdio → wrap with supergateway for streamable-http
- Dockerfile must run supergateway: `CMD ["npx", "supergateway", "node", "index.js", "--port", "8000", "--path", "/mcp"]`
- Python uses create_streamable_http_app directly
- Port 8000, path /mcp

### 3. CI/CD Fixes
- Use internal registry: 192.168.11.170:5000
- Tags: [mcp, docker, kaniko, container-build] 
- Kaniko with --insecure flags
- Auto-update ArgoCD deployment manifest with new image tag

### 4. K8s Deployment
- Use CI-built image (NOT base python/node + install)
- Health probes: tcpSocket on port 8000 (NOT httpGet — supergateway doesn't expose /health)
- ExternalSecret for credentials from Vault

### 5. Verification Checklist
- ✅ MCP SDK installed and imported
- ✅ All tools have real implementations (not stubs)
- ✅ Transport layer configured (supergateway or streamable_http)
- ✅ .gitignore excludes node_modules
- ✅ CI builds and pushes to internal registry
- ✅ K8s deployment uses CI image 
- ✅ Pod starts and listens on port 8000
- ✅ Aggregator can reach /mcp endpoint
- ✅ Tools list via mcp-call

Include the ServiceNow example as a reference implementation.

Done when:
- openclaw-skills/gitbob-mcp-deploy/SKILL.md updated with all fixes
- git commit
- NO Archivist storage