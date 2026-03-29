<div align="center">

<img src="assets/memoryops-hero.png" alt="MemoryOps Hero Image" width="800" style="border-radius: 12px; margin-bottom: 20px;" />

# MemoryOps: The Autonomous GitOps Fleet
**Secure by Design. Powered by Untouchable Memory.**

[![AHEAD × NVIDIA NemoClaw Challenge](https://img.shields.io/badge/Challenge-AHEAD_%C2%D7_NVIDIA-black?style=for-the-badge&logo=nvidia)](https://github.com/NVIDIA/NemoClaw)
[![NemoClaw Powered](https://img.shields.io/badge/Powered_by-NemoClaw-76B900?style=for-the-badge&logo=nvidia)](https://github.com/NVIDIA/NemoClaw)
[![OpenClaw Agents](https://img.shields.io/badge/Agents-OpenClaw-blue?style=for-the-badge)](https://github.com/NVIDIA/NemoClaw)

<br/>

*Built for enterprise leaders who demand autonomous scale without compromising security.*

</div>

---

## 🚀 The Executive Summary

Enterprise IT is at a breaking point. Deploying a single, "God-mode" AI agent to manage operations is a security nightmare: it requires sprawling API access, loses critical context the moment it crashes, and presents a massive risk for credential exfiltration.

**MemoryOps** is a paradigm shift. Built on the **NVIDIA NemoClaw** platform, it introduces a fully autonomous, logically segmented GitOps fleet. We guarantee:
1. **Zero-Leakage Architecture:** Agents are sandboxed and never hold API keys.
2. **Untouchable Long-Term Memory:** Corporate knowledge is permanently retained across sessions, crashes, and team handoffs.
3. **Reduced MTTR (Mean Time To Resolution):** Specialized AI agents collaborate seamlessly across GitLab, Kubernetes, ServiceNow, and Palo Alto Networks.

> *"We aren't just automating terminal commands; we are building a secure, resilient AI workforce that retains institutional knowledge forever."*

### Operating philosophy (Tesla / SpaceX style)

Every agent follows the same **five-step** discipline in [`agents/ENGINEERING_ALGORITHM.md`](agents/ENGINEERING_ALGORITHM.md): **make requirements less dumb** → **delete waste** → **optimize** → **accelerate the right process** → **automate last**. First principles over cargo cult; **the best part is no part** when it adds no value; never automate broken work.

### Fleet at a glance

**Who does what** (GitOps vs SecOps vs ITSM vs builders, **Chief** vs **ahead-chief**, workspace → `agentId` → Archivist) lives in **[`docs/FLEET-ROSTER.md`](docs/FLEET-ROSTER.md)** — start there when splitting work or registering agents in `openclaw.json`.

| Squad | Agents | Notes |
|-------|--------|--------|
| **Delivery** | Bob (`gitbob`), Kate (`kubekate`), Greg (`grafgreg`) | Kate uses **`kubernetes`** + **`argocd`** MCPs (no separate `argo` agent). |
| **Factory** | Forge (`mcp-builder`), Quill (`skill-builder`) | **`skill-builder`** primary model **`openclaw-opus-46`**; research + repo skills merged here. |

---

## 🧠 The Differentiator: Untouchable Multi-Team Memory

The defining feature of our GitOps fleet is **Archivist**—a persistent, vector-backed (Qdrant + SQLite) memory system. 

When legacy AI agents communicate, context dies with the session. In our architecture:
* **Persistent Receipts:** Agents explicitly store deployment logs, security audits, and infrastructure state directly into Archivist.
* **RBAC Namespaces:** Memory is strictly partitioned. The `pipeline` namespace holds CI/CD data, `deployer` holds cluster state, and `secops` holds firewall audits.
* **Cross-Team Synthesis:** The *Chief* orchestrator can query across all namespaces to instantly synthesize a complete picture of the enterprise—without ever interrupting the specialist execution agents. 

Nobody can "touch" or accidentally erase this corporate memory. It survives agent restarts, session drops, and complete system rebuilds.

---

## 🛡️ Zero-Leakage Architecture: NemoClaw + MCP

Security is not an afterthought; it is the foundation. We guarantee that **no agent ever holds an API key or secret token.**

1. **NemoClaw Sandboxing:** Every agent runs inside a strict, policy-controlled OpenShell sandbox. Egress is explicitly whitelisted. An agent cannot simply `curl` an external server to exfiltrate data.
2. **MCP as the Security Boundary:** We use the **Model Context Protocol (MCP)** to mathematically isolate sensitive operations:
    * Agents do not hold ServiceNow API keys; **Birdman** (`snow-birdman`) talks to the ServiceNow MCP server for incidents and **change requests** — Chief routes ITSM work there, not into raw credentials.
    * Agents do not hold Palo Alto firewall credentials; they query the Palo Alto MCP server.
    * **The CTO Guarantee:** Even if an agent goes rogue or suffers a prompt injection attack, **there are no keys to leak.** 

---

## 👥 The Fleet: Segregation of Duties

Just like your engineering organization, we divide tasks into highly specialized, least-privilege personas:

### 👔 The Coordinator
* **Chief:** The orchestrator. Takes natural language requests, formulates a safe execution plan, and stores task briefs in Archivist. The Chief *never* executes cluster or Git commands directly—enforcing a strict blast radius.

### ⚙️ The Execution Fleet
* **Bob (GitBob):** The Git pipeline specialist — repositories, merge requests, and CI via the GitLab MCP (`gitbob`).
* **Kate (KubeKate):** **Kubernetes and Argo CD** — one specialist uses both the **`kubernetes`** and **`argocd`** MCPs for live cluster ops and GitOps sync/health/rollback (`kubekate`).
* **Palo Expert:** The SecOps Auditor. Validates firewall configurations via the Palo Alto MCP, ensuring every deployment complies with enterprise security baselines.
* **Birdman (`snow-birdman`):** The ServiceNow / **change-control** specialist. Owns the **`servicenow`** MCP — incidents and **change requests** (CAB-track) so GitOps moves leave an ITSM trail (*Phoenix Project* vibes: governance without gridlock). Nothing credentialed lives in the agent — only in the MCP server.

### 🏗️ The Autonomous Builders (factory)
* **Forge (`mcp-builder`)** ships MCP server images and k8s deploys. **Quill (`skill-builder`)** researches, writes playbooks, and authors repo **`openclaw-skills/`** (primary model **`openclaw-opus-46`**). Two factory roles only — no separate research-only agent.

---

## 🏗️ Architecture Flow

**Editable diagram (judges / slide):** [`docs/diagrams/nemoclaw-fleet-architecture.drawio`](docs/diagrams/nemoclaw-fleet-architecture.drawio) — Vault, gateway, agent fleet, Archivist, Kubernetes + Argo CD + MCP aggregator + MCP backends. Open in [diagrams.net](https://app.diagrams.net).

Chief is the **single orchestrator**: the gateway routes the human to Chief, and **Chief delegates** every execution path to the right specialist (Bob, Kate, Greg, Palo Expert, **Birdman** for ServiceNow change control, factory builders). Specialists talk to **MCP servers** (keys live there) and persist **receipts** in Archivist.

```mermaid
flowchart TD
    subgraph NemoClaw["NVIDIA NemoClaw sandboxes — agents never hold keys"]
        Gateway["OpenShell Gateway & Policy Engine"]

        subgraph Fleet["Agent fleet — Chief delegates to specialists"]
            Chief["Chief<br/>(orchestrator)"]
            GitBob["Bob<br/>GitLab / CI"]
            Kate["Kate<br/>K8s + Argo CD"]
            GregNode["Greg<br/>Grafana"]
            PaloExpert["Palo Expert<br/>PAN-OS / SecOps"]
            Birdman["Birdman<br/>ServiceNow / CHG"]
            Builders["Forge + Quill<br/>mcp-builder / skill-builder"]
        end
    end

    subgraph Memory["Untouchable memory"]
        Archivist[("Archivist (Qdrant + SQLite)<br/>RBAC namespaces")]
    end

    subgraph MCP["External MCP — credentials & APIs stay here"]
        GitLabMCP["GitLab MCP"]
        ArgoMCP["Argo CD MCP"]
        K8sMCP["Kubernetes MCP"]
        GrafanaMCP["Grafana MCP"]
        PaloMCP["Palo Alto MCP"]
        SnowMCP["ServiceNow MCP"]
    end

    Gateway -->|"Telegram / chat"| Chief

    Chief -->|"delegates"| GitBob
    Chief -->|"delegates"| Kate
    Chief -->|"delegates"| GregNode
    Chief -->|"delegates"| PaloExpert
    Chief -->|"delegates"| Birdman
    Chief -->|"delegates"| Builders

    Chief <-->|"coordination & synthesis"| Archivist
    GitBob <-->|"briefs & receipts"| Archivist
    Kate <-->|"briefs & receipts"| Archivist
    GregNode <-->|"briefs & receipts"| Archivist
    PaloExpert <-->|"briefs & receipts"| Archivist
    Birdman <-->|"CHG / INC receipts"| Archivist
    Builders <-->|"briefs & receipts"| Archivist

    GitBob --> GitLabMCP
    Kate --> ArgoMCP
    Kate --> K8sMCP
    GregNode --> GrafanaMCP
    PaloExpert --> PaloMCP
    Birdman -->|"incidents & change requests"| SnowMCP

    %% Styling
    classDef memory fill:#f9f9f9,stroke:#333,stroke-width:2px;
    class Archivist memory;
    classDef mcp fill:#e1f5fe,stroke:#333,stroke-width:2px;
    class GitLabMCP,ArgoMCP,K8sMCP,GrafanaMCP,PaloMCP,SnowMCP mcp;
```

---

## ✅ Challenge Checklist

Built for the **AHEAD × NVIDIA NemoClaw Challenge**, hitting all key requirements:

- [x] **NemoClaw-Powered:** Runs on NVIDIA NemoClaw. Agents execute within OpenShell sandboxes using local LiteLLM and NVIDIA NIM (`nvidia/nemotron-3-super-120b-a12b`).
- [x] **Enterprise Use Case:** Dedicated to **DevOps & SecOps**. Tackles complex workflows—task delegation, infrastructure-as-code, and firewall auditing—proving AI can scale enterprise operations safely.
- [x] **Integrate the Ecosystem & Bonus Points:** 
  - **Palo Alto Networks:** Custom MCP server to read PAN-OS firewalls, enabling SecOps audits without agent credential leakage.
  - **ServiceNow:** Custom MCP server for ITSM ticketing and tracking.
  - **Archivist:** Shared, persistent vector-memory bridging the entire fleet.

---

## 🚀 Technical Deep Dive

Looking for the dense technical instructions on how to start the repository, configure Docker, or setup Vault? 

👉 **[See the Setup & Repository Guide (`docs/SETUP.md`)](docs/SETUP.md)**

---

<div align="center">
  <i>Engineered for the AHEAD × NVIDIA NemoClaw Challenge</i>
</div>
