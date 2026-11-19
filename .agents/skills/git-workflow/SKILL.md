---
name: git-workflow
description: Git branching, Conventional Commits formatting, direct merge to develop, and single-workspace protocol for Prism Hub sub-repositories (services/wonderlab, services/central-gateway, services/git-pulse).
---

# Git & GitHub Workflow Standards

## 1. Single-Workspace & Standard Ports Protocol

All development occurs within the primary Prism Hub workspace (editing target service directories under `services/<service>/`). Git worktrees are forbidden.

### Standard Assigned Ports:

- **Wonderlab**: Client `http://localhost:4100`, Server `http://localhost:4101/api/v1` (`make wonderlab-start`)
- **Central Gateway**: Client `http://localhost:5100`, Server `http://localhost:5101/api/v1` (`make central-gateway-start` / `make gateway-start`)
- **Git Pulse**: Client `http://localhost:6100`, Server `http://localhost:6101/api/v1` (`make git-pulse-start`)
- **Database**: Shared PostgreSQL 16 on `127.0.0.1:5432` (`make db-up`)

### Trunk-Based Execution & Direct Merge Workflow:

```bash
cd services/<service>
git fetch origin
git checkout -B <type>/<task-name> origin/develop

# Perform edits and verify (from hub root `make <service>-check` or inside service):
pnpm check

# Rebase onto latest develop and push directly:
git fetch origin
git rebase origin/develop
git push origin HEAD:develop

# Cleanup local task branch and return to develop:
git checkout develop
git pull origin develop
git branch -d <type>/<task-name>
```

- Execute all tool calls (`edit_file`, `write_file`, `run_command`) targeting the main repository.

---

## 2. Commit Message Convention

Follow Conventional Commits v1.0.0 (strictly in English):

- `feat: <description>`: Introduces a new user-facing feature.
- `fix: <description>`: Fixes a bug.
- `chore: <description>`: Maintenance, package updates, configuration adjustments.
- `docs: <description>`: Documentation changes only.
- `test: <description>`: Adding or refactoring tests.
- `refactor: <description>`: Code change that neither fixes a bug nor adds a feature.
- `ci: <description>`: CI/CD configuration and workflow updates.

---

## 3. Pre-Commit Security & Invariants

1. `git status`: Ensure no `.env*` or secrets are untracked or staged.
2. Ensure `pnpm check` passes cleanly before pushing.
3. Never force-push (`--force`) to `develop`, `main` or shared branches.
4. Direct merge: Push directly to `origin/develop`. No PRs needed for agent tasks. Each push updates the Draft Release.
5. Production release: Triggered strictly by official GitHub Release or `v*` tag.
