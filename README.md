<div align="center">

# Prism Hub

**Centralized engineering workspace, unified documentation, AI coding rulebook, and orchestration hub for the Prism ecosystem.**

[![License: MIT](https://img.shields.io/badge/License-MIT-6366f1?style=flat-square)](LICENSE)
[![Node v24](https://img.shields.io/badge/Node-v24.x-10b981?style=flat-square&logo=node.js)](https://nodejs.org)
[![pnpm 12.11.2](https://img.shields.io/badge/pnpm-12.11.2-f69220?style=flat-square&logo=pnpm)](https://pnpm.io)
[![PostgreSQL 16](https://img.shields.io/badge/PostgreSQL-16-0284c7?style=flat-square&logo=postgresql)](docker-compose.yml)

[📖 Documentation Index](docs/README.md) • [🤖 Unified AGENTS.md](AGENTS.md) • [📋 Contributing Guide](CONTRIBUTING.md)

</div>

---

## 🌌 Ecosystem Repositories (`services/`)

| Service             | Sub-Repository                                                                                               | Standard Ports (`Client / Server`) | Local DB (`127.0.0.1:5432`) | Live Production                                                                |
| :------------------ | :----------------------------------------------------------------------------------------------------------- | :--------------------------------: | :-------------------------- | :----------------------------------------------------------------------------- |
| **Wonderlab**       | [`thanhba0505/wonderlab`](https://github.com/thanhba0505/wonderlab) (`services/wonderlab`)                   |          `4100` / `4101`           | `wonderlab`                 | [wonderlab.io.vn](https://wonderlab.io.vn)                                     |
| **Central Gateway** | [`thanhba0505/central-gateway`](https://github.com/thanhba0505/central-gateway) (`services/central-gateway`) |          `5100` / `5101`           | `central_gateway`           | [central-gateway-client.vercel.app](https://central-gateway-client.vercel.app) |
| **Git Pulse**       | [`thanhba0505/git-pulse`](https://github.com/thanhba0505/git-pulse) (`services/git-pulse`)                   |          `6100` / `6101`           | `git_pulse`                 | [git-pulse-app.vercel.app](https://git-pulse-app.vercel.app)                   |

---

## 📦 Repository Architecture

```text
prism-hub/
├── AGENTS.md                   # Single unified AI coding rulebook (global + all 3 service scopes)
├── CONTRIBUTING.md             # Trunk-based workflow, Conventional Commits, Definition of Done
├── Makefile                    # Color-coded orchestration CLI (global + <service>-* commands)
├── docker-compose.yml          # Shared PostgreSQL 16 container on 127.0.0.1:5432
├── docker/postgres/            # init-databases.sql creating wonderlab, central_gateway, git_pulse
├── scripts/                    # Bootstrap, local-DB safety guardrails, status & multi-service runner
├── .agents/skills/             # Consolidated & namespaced AI skills across all services
├── docs/
│   ├── shared/                 # Architecture, dev cookbook, DB safety, CI/CD, testing, AI agents
│   ├── wonderlab/              # Wonderlab specs & ADRs (0001..0019)
│   ├── central-gateway/        # Central Gateway specs, API contracts & Slack Block Kit routing
│   └── git-pulse/              # Git Pulse specs, API contracts & HKDF token vault security
└── services/                   # Git submodules tracking origin/develop of each sub-repository
    ├── wonderlab/
    ├── central-gateway/
    └── git-pulse/
```

---

## 🚀 Quick Start

```bash
# 1. Clone Prism Hub and bootstrap submodules, envs, Postgres, dependencies & local DBs:
git clone https://github.com/thanhba0505/prism-hub.git
cd prism-hub
make init

# 2. View color-grouped commands:
make help

# 3. Start everything (all 3 clients + all 3 servers):
make start
```

### Common Orchestration Commands

- **Global (All Services / Shared Infra)**:
  - `make status` — Inspect PostgreSQL status, submodule branches, dirty trees & live ports
  - `make db-up` / `make sync-db` — Ensure shared PostgreSQL 16 + sync Prisma schemas safely (blocked on remote/Neon URLs)
  - `make check` — Run `pnpm check` sequentially across all 3 services
  - `make git-sync` — Pull latest `origin/develop` across clean submodules
  - `make stop` — Free dev ports `4100/4101`, `5100/5101`, `6100/6101`
- **Per-Service (`wonderlab-*`, `central-gateway-*` / `gateway-*`, `git-pulse-*`)**:
  - `make wonderlab-start` / `make wonderlab-start-client` / `make wonderlab-sync-db` / `make wonderlab-migrate`
  - `make central-gateway-start` (or `make gateway-start`) / `make gateway-sync-db` / `make gateway-check`
  - `make git-pulse-start` / `make git-pulse-sync-db` / `make git-pulse-migrate` / `make git-pulse-check`

---

## 📚 Documentation Index

Start at [docs/README.md](docs/README.md) for the complete index of shared platform standards and per-service technical documentation.

---

## 📄 License

Licensed under the [MIT License](LICENSE) © 2026 **thanhba0505**.
