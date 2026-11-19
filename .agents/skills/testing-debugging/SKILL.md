---
name: testing-debugging
description: Testing standards, smoke testing procedures, and systematic debugging methodologies across Prism Hub client and server services.
---

# Testing & Debugging Playbook

## 1. Lean Testing Pyramid

Prism Hub services enforce a **lean, core-only testing policy** to keep CI workflows fast and free of test bloat:

- **Frontend Mathematical Engine Tests (Vitest)**: High-value tests verifying mathematical correctness, statistical convergence, and quantum/probabilistic models of paradoxes (e.g. `birthday-math.test.ts`, `monty-hall.test.ts`, `quantum-math.test.ts`, `zeno-math.test.ts`, `game-theory-math.test.ts`).
- **Backend Service Unit Tests (Jest)**: Core domain logic, authentication/authorization, password hashing, soft-delete mechanisms, and mutations in NestJS services (`*.service.spec.ts`).
- **Backend E2E Tests (Supertest)**: End-to-end tests validating the full NestJS HTTP pipeline (`/test/*.e2e-spec.ts`), including guards, health checks, cookies, and route prefixing.
- **Smoke Tests**: Automated script (`scripts/smoke-test.sh`) verifying HTTP 200 on all primary public routes, health endpoints, and Swagger UI.

### Strict Scope Boundaries:

- **DO NOT** write unit tests for generic React UI components (buttons, dropdowns, inputs, modals), static dictionaries (essays, curated lists), trivial utilities (`cn()`), or pass-through controller mocks.
- Tests must remain fast, deterministic, and focused on mission-critical calculations and security-sensitive backend flows.

## 2. Systematic Debugging Rules

- **Reproduce First**: Never apply speculative fixes without first running a failing test or observing the exact error trace.
- **Check Boundaries**: Verify environment variable loading, port bindings (4100 vs 4101), CORS headers, and JSON serialization.
- **No Test Circumvention**: Do not skip tests (`it.skip`), silence TypeScript errors (`@ts-ignore`), or disable linter rules without justification.
