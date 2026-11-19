# AI Coding Agents & Consolidated Skills Playbook

**Prism Hub** centralizes all universal AI engineering rules into root [`AGENTS.md`](../../AGENTS.md) and keeps [`.agents/skills/`](../../.agents/skills/) strictly scoped to high-density, service-specific playbooks to minimize per-turn context and token overhead.

---

## 1. Root Guidelines & Token-Lean Skill Model

- **Unified Rulebook ([`AGENTS.md`](../../AGENTS.md))**: Auto-loaded on every turn; covers all cross-service rules (ports, single-workspace Git workflow, S2S security, DB migration lockouts, TypeScript zero-`any`, Next.js/NestJS conventions, React anti-re-render discipline, and lean verification).
- **Zero Duplicate Skills**: Cross-service rules already present in `AGENTS.md` and unused third-party skill packs are excluded from `.agents/skills/` so agents never waste tokens or tool calls reading redundant playbooks.
- **Service-Scoped Skills ([`.agents/skills/`](../../.agents/skills/))**: Loaded on demand only when working on a specific service's UI or OAuth2 SSO layer.

---

## 2. `.agents/skills/` Catalog

| Skill                           | Scope           | Focus                                                                                           |
| :------------------------------ | :-------------- | :---------------------------------------------------------------------------------------------- |
| **`wonderlab-frontend-design`** | Wonderlab       | _"Clean Paper & Lab Editorial"_, `<MathFraction>` / LaTeX math, Anti-AI slop, 1200x630 OG cards |
| **`gateway-frontend-design`**   | Central Gateway | _"Cosmic Violet & Frosted Glass"_, starfield canvas, silhouette layers, glass primitives        |
| **`gateway-auth-sso`**          | Central Gateway | OAuth2 Authorization Code + PKCE (`S256`), `gateway_session` cookies, fail-fast error codes     |
| **`gitpulse-frontend-design`**  | Git Pulse       | _"Precision Developer Dark"_ (`#0F172A` Cool Slate), `InteractiveBackdrop`, a11y, `vi`/`en` UI  |

---

## 3. Continuous Knowledge Persistence Invariant

1. Whenever a user establishes a persistent rule, stylistic constraint, security requirement, or workflow standard across any session, persist it autonomously into [`AGENTS.md`](../../AGENTS.md), the matching [`docs/`](../README.md) specification, and the relevant playbook in `.agents/skills/` within the same turn.
2. Keep skill frontmatter descriptions (`<= 15 words`) and bodies compact, high-signal, and free of prose filler.
