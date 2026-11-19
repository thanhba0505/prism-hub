# AI Coding Agents & Consolidated Skills Playbook

**Prism Hub** centralizes all AI engineering rules and reusable agent playbooks into a single root source of truth so assistants maintain complete cross-ecosystem consistency without duplicated rule drift across child repositories.

---

## 1. Root Guidelines & Consolidation Model

- **Unified Rulebook**: [`AGENTS.md`](../../AGENTS.md) at the root of `prism-hub` defines universal ecosystem invariants plus service-scoped constraints (`services/wonderlab/`, `services/central-gateway/`, `services/git-pulse/`).
- **Consolidated Skills**: All project skills live in [`.agents/skills/`](../../.agents/skills/), cleanly namespaced where design domains diverge.
- **Workspace Root Discipline**: Always open `prism-hub/` as the primary workspace root. Child repositories intentionally omit duplicate `docs/`, `.agents/`, and local `AGENTS.md` copies.

---

## 2. Consolidated `.agents/skills/` Catalog

| Skill                           | Scope           | Focus                                                                                               |
| :------------------------------ | :-------------- | :-------------------------------------------------------------------------------------------------- |
| **`git-workflow`**              | All Services    | Trunk-Based `develop` workflow, Conventional Commits v1.0.0, port assignments, zero worktrees       |
| **`nextjs-development`**        | All Frontends   | Next.js 15 App Router, React 19 RSC/Client boundaries, `pnpm dev` rule, SEO/OG, state discipline    |
| **`nestjs-backend`**            | All Backends    | NestJS 10 modules, `/api/v1` global prefix, DTO `ValidationPipe`, Swagger `/api/docs`, Zero-`any`   |
| **`testing-debugging`**         | All Services    | Lean core-only testing pyramid, smoke testing, root-cause reproduction discipline                   |
| **`wonderlab-frontend-design`** | Wonderlab       | _"Clean Paper & Lab Editorial"_, `<MathFraction>` / LaTeX math, Anti-AI slop, 1200x630 OG cards     |
| **`gateway-frontend-design`**   | Central Gateway | _"Cosmic Violet & Starry Night Frosted Glass"_, canvas starfield, silhouette layers, pill controls  |
| **`gateway-auth-sso`**          | Central Gateway | OAuth2 Authorization Code + PKCE (`S256`), `gateway_session` cookies, error contracts               |
| **`gitpulse-frontend-design`**  | Git Pulse       | _"Precision Developer Dark"_ (`#0F172A` / Cool Slate Elevated), `InteractiveBackdrop`, `vi`/`en` UI |
| **`neon` / `neon-*`**           | Cloud Postgres  | Neon Serverless Postgres, Auth, Storage, Functions, AI Gateway, Realtime reference playbooks        |

---

## 3. Continuous Knowledge Persistence Invariant

1. Whenever a user establishes a persistent rule, stylistic constraint, security requirement, or workflow standard across any session, persist it autonomously into [`AGENTS.md`](../../AGENTS.md), the matching [`docs/`](../README.md) specification, and the relevant playbook in `.agents/skills/` within the same turn.
2. Never wait for explicit reminders to update documentation when architectural contracts change.
