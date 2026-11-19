# Testing & Code Quality Standards

---

## 1. TypeScript & Clean Code Non-Negotiables

- **Strict Zero-`any` Policy**:
  - Forbidden: `any`, `Record<string, any>`, `Array<any>`, `@ts-ignore`, `@ts-nocheck`.
  - Required: `unknown` + runtime narrowing / type guards, or generic constraints `<T extends Record<string, unknown>>`.
- **Explicit Contracts & Null Safety**:
  - Explicit TypeScript interfaces/DTOs for all domain entities, props, state, and API responses.
  - Handle optionality safely (`?.`, `??`, guard clauses) under `strictNullChecks` / `noUncheckedIndexedAccess`; avoid `!`.
- **Clean Architecture**:
  - Guard clauses with early returns (maximum 2 levels of nesting), single-purpose helpers, zero duplicated logic.
  - ESLint enforced with `--max-warnings 0`; code formatted consistently via Prettier (`singleQuote: true`, `tabWidth: 2`, `printWidth: 100`).
  - Zero-layout-shift scrollbars across all frontends via `scrollbar-gutter: stable` on root/scroll containers (`html`, `.custom-scrollbar`, `.gp-scroll-area`, `.overflow-y-auto`), paired with WCAG 1.4.11 (`>= 3:1`) `scrollbar-color` tokens and `@media (prefers-contrast: more)` overrides.

---

## 2. React Anti-Re-render Standard

1. **Zero Derived State in `useEffect`**: Compute derived values inline during render or with `useMemo`; never mirror props into state inside effects.
2. **Event-Driven Side Effects**: Trigger API requests, dispatches, and mutations inside event handlers (`onClick`, `onSubmit`, `onChange`), reserving `useEffect` strictly for external system synchronization (DOM listeners, Canvas, Workers, WebSockets).
3. **Form Watcher Isolation**: Scope `useWatch` / `watch()` to leaf components or read via `getValues()` on submit.
4. **`useRef` for High-Frequency State**: Store animation handles, Canvas 2D contexts, workers, and tight loop indices in `useRef`, throttling UI state updates.
5. **Component Granularity**: Decouple slider/control panes from expensive canvas or data view siblings and memoize callbacks passed to `React.memo` components with `useCallback`.

---

## 3. Lean, Core-Only Testing Philosophy

Prism Hub optimizes CI feedback speed (< 5s unit suites) by focusing strictly on mission-critical logic:

- **What MUST Be Tested**:
  - **Core Algorithms & Math**: Wonderlab paradox engines and probability convergence (Vitest), Git Pulse PR/commit parsers & aggregation helpers.
  - **Security & Backend Services**: Password hashing (`Argon2id`), JWT/OAuth2 PKCE flows, HKDF + AES-256-GCM encryption/redaction, S2S HMAC verification, and notification routing (`*.spec.ts`).
  - **High-Value E2E Flows**: NestJS HTTP lifecycle tests (`/health`, `/auth` in `server/test/*.e2e-spec.ts`).
- **What Must NOT Be Tested (Zero Test Bloat)**:
  - Generic UI wrapper components (buttons, modals, inputs), static dictionaries, trivial helpers (`cn()`), or pass-through controller mocks.
- **No Skipped / Relaxed Tests**: Never commit `it.skip` or silence failures to make `make check` pass.

---

## 4. Verification Pipeline (`make check`)

Before committing or pushing directly to `develop` inside any service:

```bash
make <service>-check   # or pnpm check inside services/<service>
```

Executes in fail-fast order: `format:check` -> `lint` -> `typecheck` -> `test` -> (`test:e2e` on Wonderlab) -> `build`.
