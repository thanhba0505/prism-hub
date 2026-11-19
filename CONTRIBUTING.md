# Contributing to Prism Hub Ecosystem

Welcome to **Prism Hub** — the unified workspace, documentation center, and orchestration hub for **Wonderlab**, **Central Gateway**, and **Git Pulse**.

---

## 1. Commit Convention (Conventional Commits v1.0.0)

All commits across `prism-hub` and its sub-repositories (`services/*`) must be written in English following Conventional Commits:

- `feat: <description>`: New feature or user-facing capability
- `fix: <description>`: Bug fix
- `chore: <description>`: Maintenance, dependencies, configuration, or release sync
- `docs: <description>`: Documentation and ADR changes
- `test: <description>`: Unit, integration, or E2E test updates
- `refactor: <description>`: Code restructuring without behavior changes
- `ci: <description>`: CI/CD workflows and deployment verification scripts

_Example_: `feat(git-pulse): group activity scanner cards by task and personal org`

---

## 2. Trunk-Based Development Workflow

Each service repository under `services/` (`wonderlab`, `central-gateway`, `git-pulse`) uses a trunk-based workflow targeting `develop` (`main` is reserved strictly for automated production releases):

1. **Create a Task Branch off `origin/develop`**:
   ```bash
   cd services/<service>
   git fetch origin
   git checkout -B <type>/<task-name> origin/develop
   ```
2. **Develop & Verify**:
   - Follow all unified standards in [`AGENTS.md`](AGENTS.md) and service docs in [`docs/`](docs/README.md).
   - Never commit `.env*` files, secrets, or tokens.
   - Start dev servers via `make <service>-start` (or `pnpm dev` — never `next start`).
   - Run the full verification pipeline from hub root or service directory:
     ```bash
     make <service>-check
     ```
3. **Merge Directly to `develop` & Clean Up**:
   ```bash
   cd services/<service>
   git fetch origin && git rebase origin/develop && git push origin HEAD:develop
   git checkout develop && git pull origin develop && git branch -d <type>/<task-name>
   ```
4. **Update Documentation Centrally**:
   - All architectural docs, API references, ADRs, and AI agent guidelines live centrally in `prism-hub/docs/` and `prism-hub/AGENTS.md` (not inside individual service repositories).

---

## 3. Definition of Done

- [ ] `make <service>-check` passes with zero warnings/errors (`format:check`, `lint`, `typecheck`, `test`, `test:e2e` where applicable, `build`).
- [ ] Core domain math, auth, S2S, or security logic includes deterministic tests without UI test bloat.
- [ ] Zero hardcoded secrets, localhost dev leaks, or direct remote Neon database operations.
- [ ] Shared docs in `prism-hub/docs/` or `prism-hub/AGENTS.md` updated if architecture, endpoints, or standards changed.
