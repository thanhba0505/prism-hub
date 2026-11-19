# AGENTS.md — Prism Hub Unified AI Coding Guidelines

Authoritative engineering rulebook for AI coding assistants operating anywhere in the **Prism Hub** ecosystem (`services/wonderlab`, `services/central-gateway`, and `services/git-pulse`).

> [!CRITICAL]
>
> ### 🚨 Mandatory Single-Workspace, Submodule & Standard Ports Protocol
>
> 1. **Primary Hub Workspace**: Operate from the `prism-hub` root workspace, editing target service files under `services/<service>/`. All consolidated documentation lives in `docs/` (`docs/shared/` + `docs/<service>/`) and all skills live in `.agents/skills/`.
> 2. **No Worktrees**: Strictly forbid creating or using git worktrees. Dev servers run directly against assigned standard ports:
>    - **Wonderlab**: Client `http://localhost:4100` | Server `http://localhost:4101` (`/api/v1`)
>    - **Central Gateway**: Client `http://localhost:5100` | Server `http://localhost:5101` (`/api/v1`)
>    - **Git Pulse**: Client `http://localhost:6100` | Server `http://localhost:6101` (`/api/v1`)
>    - **Database**: Shared PostgreSQL 16 on `127.0.0.1:5432` (`wonderlab`, `central_gateway`, `git_pulse`)
> 3. **Sub-Repo Trunk-Based Execution Workflow**:
>    ```bash
>    cd services/<service>
>    git fetch origin && git checkout -B <type>/<task-name> origin/develop
>    # Edits & verification (`make <service>-check` from hub root or `pnpm check` inside service):
>    pnpm check
>    # Direct push to develop & cleanup:
>    git fetch origin && git rebase origin/develop && git push origin HEAD:develop
>    git checkout develop && git pull origin develop && git branch -d <type>/<task-name>
>    ```
>    After pushing submodule changes, update the submodule pointer in `prism-hub` when appropriate (`git submodule update --remote --merge`).

---

## 1. Ecosystem Overview & Tooling

- **Runtime & Package Manager**: Node `v24.x` (`.nvmrc`), `pnpm@12.11.2`. Never use `npm` or `yarn`.
- **Makefile Orchestration**:
  - **Global (Unprefixed)**: `make init`, `make start`, `make db-up`, `make sync-db`, `make check`, `make status`, `make git-sync`, `make stop`, `make clean`.
  - **Per-Service (`<svc>-*`)**: `make wonderlab-*`, `make central-gateway-*` (short alias `make gateway-*`), `make git-pulse-*` (e.g. `make wonderlab-sync-db`, `make gateway-start`, `make git-pulse-migrate NAME=...`).
- **Consolidated Documentation**: Never re-create `docs/`, `AGENTS.md`, `CONTRIBUTING.md`, `.agents/`, or `docker-compose.yml` inside `services/<service>/`; child repositories maintain only `README.md` pointing back here.

---

## 2. Security & Production Database Guardrails

- **Zero Secret Leaks**: Never commit `.env*` or API tokens (only `.env.example` templates belong in Git).
- **Client Env Boundaries**: Only `NEXT_PUBLIC_*` variables may appear in `client/` code. Never bundle DB credentials, Slack bot tokens, or S2S/encryption keys into frontend code.
- **Production Database Safety & Migration Protocol (NON-NEGOTIABLE)**:
  - **STRICTLY FORBID** executing manual or ad-hoc database migrations, schema pushes, or seed scripts (`prisma migrate deploy`, `prisma db push`, `prisma db seed`) against remote **Neon** production databases from local terminal or agent turns.
  - Production migrations run **exclusively** inside official automated Release builds (`v*.*.*`).
  - Hub DB commands enforce `scripts/check-local-db.sh` (rejects any `DATABASE_URL` whose hostname is not `127.0.0.1`, `localhost`, or `::1`).
- **CORS**: Explicit origin whitelisting (`CORS_ORIGINS` / `CORS_ORIGIN`), strictly scoped to browser frontends, never to server-to-server HTTP traffic.
- **Service-to-Service (S2S) & Vault Standard**:
  - Dynamic connections stored in PostgreSQL `service_connections` (`slug`, `domain`, `apiPrefix`, `apiKey`, `incomingSecret`, `isActive`). Never introduce static backend gateway secrets where S2S registry applies.
  - Secrets at rest encrypted via AES-256-GCM (`enc:v1:<iv>:<tag>:<ciphertext>`) using `s2s-vault.util.ts` and dedicated 256-bit `S2S_ENCRYPTION_KEY` (production fail-fast).
  - Inbound S2S verified via `S2SAuthGuard` (`crypto.timingSafeEqual`) with HMAC-SHA256 signatures and 5-minute (`300,000ms`) replay window (`X-S2S-Service`, `X-S2S-Timestamp`, `X-S2S-Signature`); outbound calls use `S2SService.call(...)`.

---

## 3. Universal Code, TypeScript & Verification Standards

- **Strict Zero-`any` Policy**:
  - Forbidden: `any`, `Record<string, any>`, `Array<any>`, `@ts-ignore`, `@ts-nocheck`.
  - Use `unknown` + runtime narrowing / type guards or constrained generics `<T extends Record<string, unknown>>`.
- **Explicit Contracts & Null Safety**: Define explicit interfaces/DTOs for all domain entities, props, state, and endpoints. Handle optionality via `?.`, `??`, or guard clauses; avoid `!`.
- **NestJS & Next.js Conventions**:
  - **NestJS Backends**: Global `/api/v1` prefix, `GET /api/v1/health`, `/api/docs` Swagger (dev), global `ValidationPipe` (`whitelist: true, forbidNonWhitelisted: true, transform: true`), and `class-validator` DTOs.
  - **Next.js Frontends**: App Router (`src/app/(public)/`, `src/app/admin/`), default to React Server Components (`'use client'` strictly for hooks/events/browser APIs), `@/` path alias.
- **Clean Code**: Guard clauses, early returns (max 2 levels of nesting), single-purpose functions, zero duplicate logic, grouped imports.
- **Minimum Font Size (`>= 12px`) Across ALL Apps**: Strictly forbid text smaller than `12px` (`text-xs`). Never use `text-[11px]`, `text-[10px]`, `text-[8px]`, etc.
- **Zero-Layout-Shift Symmetric Scrollbars (`scrollbar-gutter: stable both-edges`, `5px`)**: All root/viewport and inner vertical scroll containers (`html`, `.custom-scrollbar`, `.gp-scroll-area`, `.overflow-y-auto`) must enforce `scrollbar-gutter: stable both-edges` with ultra-slim `5px` `::-webkit-scrollbar` pills, WCAG 1.4.11 (`>= 3:1`) contrast tokens, `@media (prefers-contrast: more)` overrides, and `@supports not selector(::-webkit-scrollbar)` `scrollbar-width: thin` Firefox fallbacks.
- **React Anti-Re-render Standard**:
  - **Zero Derived State in `useEffect`**: Compute inline during render or with `useMemo`.
  - **Event-Driven Side Effects**: Trigger mutations/dispatches inside event handlers (`onClick`, `onSubmit`), reserving `useEffect` strictly for external systems (DOM listeners, Canvas, Workers, WebSockets).
  - **Form Watcher Isolation**: Isolate `useWatch` / `watch()` to leaf components or read via `getValues()`.
  - **`useRef` for High-Frequency State**: Store animation handles, Canvas contexts, workers, and iteration counters in `useRef`, throttling React state updates.
  - **Component Granularity**: Split controls from heavy canvas/data siblings; stabilize callbacks passed to `React.memo` children via `useCallback`.
- **Unified Verification (`make <svc>-check` / `pnpm check`)**:
  - Always run full `format:check`, `lint` (`--max-warnings 0`), `typecheck`, `test`, (`test:e2e` for Wonderlab), and `build` before claiming completion.
  - Follow lean, core-only testing (`docs/shared/testing-and-quality.md`): test math engines, security/crypto logic, auth/permissions, and high-value E2E; forbid bloat unit tests for UI wrappers, static dictionaries, or pass-through mocks.
- **Dev Server Standard (`pnpm dev` Only)**:
  - **STRICTLY run `pnpm dev` / `pnpm dev:client` / `pnpm dev:server`** (or `make start` / `make <svc>-start`).
  - **NEVER run `pnpm start` or `next start`** locally — `next start` locks to an immutable `BUILD_ID` and breaks styles/chunks (`400 Bad Request`) whenever `pnpm check` or `next build` updates `.next/`.

---

## 4. Git Workflow, Versioning & Releases (All Sub-Repos)

- **Conventional Commits**: `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`, `ci:` — strictly in English.
- **Direct Merge to `develop`**: No PRs needed for agent tasks; branch off `origin/develop`, verify with `pnpm check`, rebase onto `origin/develop`, push `HEAD:develop`, and clean up the task branch.
- **Single Source of Truth for Versioning**: Root `package.json` (`version`) is authoritative across client (`next.config.ts`) and server (`version.ts`). Never bump versions on regular commits or draft releases; versions bump exclusively on official releases (`release: [published]` or tag `v*.*.*`).
- **Automated Production CD**: Published releases merge `origin/develop` into `main` (`--no-ff`), bump & tag version, sync back to `develop`, trigger Vercel Deploy Hooks, update live GitHub Deployment environments (`in_progress` ⏳ -> `success` 🟢 / `failure` ❌) via `scripts/verify-deployment.sh`, and route alerts through Central Gateway.

---

## 5. Service Scope: `services/wonderlab/`

Refer to [`.agents/skills/wonderlab-frontend-design/SKILL.md`](.agents/skills/wonderlab-frontend-design/SKILL.md) and [`docs/wonderlab/`](docs/wonderlab/architecture.md).

- **Architecture**: BFF Auth Proxy delegating login, registration, and Google Auth to Central Gateway via S2S, syncing local shadow profiles (`id`, `username`, `email`, `role`, `avatarUrl`, `isActive`) with zero local password fallbacks and offline JWT cookie validation (`Role.ADMIN` required for `/admin`).
- **UI Standard ("Clean Paper & Lab Editorial")**:
  - Slate-100 canvas (`#f1f5f9`), crisp white cards (`#ffffff`), hairline borders (`border-slate-300/85`), soft layered shadows, semantic accents (Cobalt Blue `#2563eb` physics, Amber `#d97706` probability, Violet `#7c3aed` paradox, Emerald `#059669` logic).
  - Fonts: `Be Vietnam Pro` (sans/body), `Space Grotesk` (headings `h2` standardized to `18px`), `JetBrains Mono` (`tabular-nums`).
  - **Mathematical Typography**: Forbid raw ASCII math (`n/3`, `x^2`, `sqrt`, `sum`) with variables; require `<MathFraction>`, `<sup>`, `<sub>`, `&radic;`, or LaTeX `\frac{}{}`. Single exception: constant arithmetic ratios (`2/3`, `1/3`, `50/50`).
  - **Anti-AI Slop**: No purple/pink gradients on buttons/text; no stacked muddy glassmorphism; asymmetric Bento grids instead of cookie-cutter 3-column boxes; no SaaS buzzwords; calibrated radiuses (`rounded-md`/`lg`/`xl`); max 2 nested border boxes; zero tech boasting, dev narration, localhost endpoints, or fake stats in public UI.
- **SEO & Dynamic OG**: Typed `sitemap.ts` / `robots.ts` disallowing `/admin`, `/my-account`, `/api/`; `generateMetadata` without duplicating `| Wonderlab`; `schema-dts` JSON-LD sanitized with `.replace(/</g, '\\u003c')`; `1200x630` `opengraph-image.tsx` loading local `Be Vietnam Pro` TTFs from `client/src/assets/fonts/`.

---

## 6. Service Scope: `services/central-gateway/`

Refer to [`.agents/skills/gateway-frontend-design/SKILL.md`](.agents/skills/gateway-frontend-design/SKILL.md), [`.agents/skills/gateway-auth-sso/SKILL.md`](.agents/skills/gateway-auth-sso/SKILL.md), and [`docs/central-gateway/`](docs/central-gateway/architecture.md).

- **Role**: Ecosystem **IAM Master**, **OAuth2 Authorization Code + PKCE (`S256`)** SSO Hub, Slack Block Kit notification broker, and admin user/service control plane.
- **Guards**: Backend S2S endpoints enforce `ApiKeyGuard` (strict HMAC-SHA256); notification endpoints enforce `NotificationAuthGuard` (S2S HMAC or timing-safe `Bearer GATEWAY_SECRET_KEY`); user/admin management uses `AdminOrS2SGuard`. Session cookies (`gateway_session`) must be `HttpOnly`, `SameSite: Lax`, and `Secure` in production.
- **UI Standard ("Cosmic Violet & Frosted Glass")**: Deep sky gradient (`#130624` -> `#631f8f`), frosted cards (`backdrop-blur-2xl`, `bg-white/[0.08]`, `border-white/20`), capsule pill inputs, glowing solid white action buttons, isolated canvas starfield + mountain/pine silhouettes respecting `prefers-reduced-motion`.

---

## 7. Service Scope: `services/git-pulse/`

Refer to [`.agents/skills/gitpulse-frontend-design/SKILL.md`](.agents/skills/gitpulse-frontend-design/SKILL.md) and [`docs/git-pulse/`](docs/git-pulse/architecture.md).

- **Brand Naming**: Strictly named **`Git Pulse`** (spaced, never `Git-Pulse`).
- **Token & AI Key Vault Cryptographic Security**:
  - GitHub PATs/OAuth tokens (`git_accounts`) and personal AI provider keys (`ai_connections`, e.g., Google Gemini) encrypted at rest via **AES-256-GCM** + **Per-User HKDF (`crypto.hkdfSync`)** (`keyVersion` rotation, production fail-fast `ENCRYPTION_KEY`/`GITHUB_TOKEN_ENCRYPTION_KEY`).
  - Automatic over-privileged scope detection (`delete_repo`, `admin:org`), Fine-Grained PAT `expiresAt` tracking, zero-leak regex redaction (`ghp_`, `github_pat_`, `gho_`, `AIza...`, `AQ....`, `sk-...`, `gsk_...`), immutable `token_audit_logs`, and `@Throttle` (max 5 req/min) on PAT/OAuth/AI-key routes.
- **UI Standard ("Precision Developer Dark")**:
  - Tailwind Cool Slate Elevated surfaces over `#0F172A` (`slate-900`) canvas: `.gp-card` (`#1E293B` / `rgba(30,41,59,0.86)`), `.gp-modal-surface`, `.gp-glass-panel`, elevated nested `#273549`, recessed `#152033` inputs, crisp `#334155` borders, `#94A3B8` muted text, `Sky-500` (`#0EA5E9`) primary accent; `Plus Jakarta Sans`, `Inter`, `JetBrains Mono`.
  - Interactive pointer-driven `InteractiveBackdrop` (deactivates cleanly on pointer exit) paired with Pause/Play ambient motion toggle (`useAmbientMotionPreference`) and `IntroScreen`. Strictly forbid idle continuous RAF starfields, scanline overlays, spinning logos, radar/sci-fi jargon, internal crypto boasting, or native `window.alert()` / `window.confirm()`.
  - Standard primitives (`ShowcaseCard`, `DropdownMenu`, `Select`, `Input`, `SegmentedControl`, `<dialog>` `ModalDialog`), pinned header + inner `custom-scrollbar` + footer shell, select-driven AI provider console (`GitHub Models`, personal `Google Gemini` BYOK connections, live availability verification — no WebLLM), full `vi`/`en` UI i18n decoupled from AI report language.

---

## 8. Non-Negotiable Agent Rules & Knowledge Persistence

1. **Read Before Writing**: Inspect target files and specs before editing.
2. **No Fake Completions**: Never claim completion without executing verification (`pnpm check` / `make <svc>-check` / script tests) and observing outputs.
3. **No Scope Creep**: Deliver strictly what was requested.
4. **Continuous Knowledge Persistence**: Whenever the user establishes an ongoing engineering rule, architectural standard, or workflow convention, autonomously update this `AGENTS.md`, `docs/`, and `.agents/skills/` within the same turn.
