# Prism Hub Documentation Index

Centralized architectural specifications, operational playbooks, and engineering standards for the **Prism Hub** ecosystem (**Wonderlab**, **Central Gateway**, and **Git Pulse**).

---

## 1. Shared Ecosystem Guides (`docs/shared/`)

| Guide                                                             | Summary                                                                                                          |
| :---------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------- |
| [Ecosystem Architecture & Security](shared/architecture.md)       | Service topology, standard port table, S2S HMAC-SHA256 & AES-256-GCM Vault, and OAuth2 PKCE IAM sync.            |
| [Local Development & Makefile Guide](shared/development.md)       | Workspace initialization (`make init`), colored grouped Makefile commands, dev server rules (`pnpm dev` only).   |
| [Database & Neon Safety Protocol](shared/database.md)             | Shared PostgreSQL 16 (`127.0.0.1:5432`), local guardrails (`check-local-db.sh`), Neon production migration bans. |
| [CI/CD & Automated Releases](shared/ci-cd-and-deployment.md)      | Parallel CI jobs, Release Drafter, Vercel Deploy Hooks, live GitHub Deployments, and Slack routing.              |
| [Testing & Code Quality Standards](shared/testing-and-quality.md) | Strict Zero-`any` TypeScript, ESLint zero-warning policy, lean core-only testing, and React state discipline.    |
| [AI Agents & Skills Architecture](shared/ai-agents.md)            | Unified `AGENTS.md`, namespaced `.agents/skills/` catalog, and Continuous Knowledge Persistence rules.           |

---

## 2. Service Documentation

### Wonderlab (`services/wonderlab`)

- [Architecture Overview](wonderlab/architecture.md)
- [Frontend Engineering & UI Standards](wonderlab/frontend.md)
- [Backend Architecture & S2S Proxy](wonderlab/backend.md)
- [Environment Variables](wonderlab/environment.md)
- [Deployment Architecture (Vercel & Neon)](wonderlab/deployment.md)
- [Architecture Decision Records (`0001`–`0019`)](wonderlab/decisions/)

### Central Gateway (`services/central-gateway`)

- [Architecture & Notification Broker](central-gateway/architecture.md)
- [REST API Reference (Notifications & OAuth2/IAM)](central-gateway/api-reference.md)
- [Slack App Setup & Block Kit Routing](central-gateway/slack-integration.md)
- [Deployment Architecture & Verification](central-gateway/deployment.md)

### Git Pulse (`services/git-pulse`)

- [Architecture & Dual-Engine AI](git-pulse/architecture.md)
- [REST API Reference](git-pulse/api-reference.md)
- [Token Vault & HKDF Cryptographic Security](git-pulse/security.md)
- [Deployment Architecture & Operations](git-pulse/deployment.md)

---

## 3. Repository Root Standards

- [Unified AI Coding Rules (`AGENTS.md`)](../AGENTS.md)
- [Contributing & Trunk-Based Git Workflow (`CONTRIBUTING.md`)](../CONTRIBUTING.md)
