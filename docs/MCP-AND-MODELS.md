# MCP validation & NVIDIA model alignment

Use this before demos and before the challenge video so **tools and models** match what you claim.

## 0. Aggregator ↔ pod wiring (Palo + ServiceNow + K8s)

See **[`deploy/k8s/mcp-aggregator/README.md`](../deploy/k8s/mcp-aggregator/README.md)** — each MCP pod serves SSE at **`/mcp/sse`**; fix **404** by aligning Ingress/proxy paths to that backend.

## 1. Validate MCP URLs (reachability)

From the repo root:

```bash
./scripts/validate-mcp-endpoints.sh
```

Optional: point at a redacted config for another host:

```bash
MCP_CONFIG=config/mcporter.example.json ./scripts/validate-mcp-endpoints.sh
```

**What this checks:** TCP/HTTP reachability and status code on `GET`. It does **not** prove MCP `tools/list` works — for that, use **OpenClaw** with `mcporter` or your gateway session and invoke a trivial tool.

### Common issues

| Symptom | Likely fix |
|--------|------------|
| **404** on `…/panos/mcp` | Aggregator route must forward to **`paloalto-mcp`** pod MCP path (`/mcp/sse` / messages). GitLab hostnames are for **code/registry**, not the running MCP URL. |
| **ServiceNow** | This fleet uses **`http://<aggregator>:8080/snow/mcp`** (see `config/mcporter.json`). |
| **Connection refused / timeout** to `192.168.x.x` | Run the script **on ROC** (or VPN into the lab). CI / another laptop will not see private IPs. |
| **406** on Brave `/mcp` | Often **wrong `Accept` header** for streamable HTTP; Brave MCP may require POST or specific headers — use the Brave skill / `mcp-call` flow instead of raw `curl`. |
| **Archivist `/mcp/sse`** | **SSE** may not return useful `GET` without an MCP client; rely on **`GET /health` → 200** on `:3100` first. |

## 2. NVIDIA NIM models (OpenClaw `nvidia` provider)

NemoClaw’s reference stack documents these **OpenAI-compatible** model IDs on `https://integrate.api.nvidia.com/v1`:

| Model id | Typical use |
|----------|----------------|
| `nvidia/nemotron-3-super-120b-a12b` | Default flagship — agents, long context ([NIM ref](https://docs.api.nvidia.com/nim/reference/nvidia-nemotron-3-super-120b-a12b)) |
| `nvidia/llama-3.1-nemotron-ultra-253b-v1` | Larger / alternate reasoning |
| `nvidia/llama-3.3-nemotron-super-49b-v1.5` | Efficient “super” tier |
| `nvidia/nemotron-3-nano-30b-a3b` | Fast / high-volume |

Your **`~/.openclaw/openclaw.json`** `models.providers.nvidia.models` should list the IDs you actually use so the gateway can route and show names correctly. Prefer **`.5`** on the 49B id if that is what NIM exposes today.

**Embeddings / Archivist:** keep `EMBED_MODEL` in `stack/.env` aligned with [NVIDIA embedding NIMs](https://docs.api.nvidia.com/nim/reference/) (e.g. `nvidia/nv-embedqa-e5-v5` if that is what you run).

## 3. LiteLLM (`stack/litellm-config.yaml`)

- **Gitignored** real file; **tracked** `stack/litellm-config.yaml.example` should mirror:
  - **Bedrock** aliases: `openclaw-haiku`, `openclaw-sonnet-45`, `openclaw-opus-46`, etc.
  - **NVIDIA** routes: `openai/nvidia/<id>` + `api_base: https://integrate.api.nvidia.com/v1` + `api_key: os.environ/NVIDIA_API_KEY`

After edits:

```bash
systemctl --user restart litellm-bedrock.service
curl -sS http://127.0.0.1:4000/v1/models -H "Authorization: Bearer sk-litellm-local" | jq .
```

Confirm every **`openclaw-*`** and **`nvidia/...`** model you reference in `openclaw.json` appears here (or use the **`nvidia`** provider in `openclaw.json` directly for Nemotron, which bypasses LiteLLM).

## 4. Winning the narrative (judges)

- **Say “Nemotron 3 Super 120B”** by name for agents on the `nvidia` provider (ahead-chief, skill-builder, palo-expert, etc.).
- **Keep GitOps agents** on Bedrock via LiteLLM if that is your cost/ops choice — that is still “enterprise stack”; just **name NVIDIA explicitly** where you use it.
- **MCP**: one screenshot or terminal line showing **`tools/list`** or a successful **`kubernetes` / `archivist_store`** call proves integrations better than HTTP status codes alone.

## 5. Public repo hygiene

Tracked **`config/mcporter.json`** may contain lab IPs. For GitHub, maintain **`config/mcporter.example.json`** (placeholders) and copy to `mcporter.json` on each environment.
