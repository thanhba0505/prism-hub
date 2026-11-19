# Local Development & Makefile Cookbook

---

## 1. Prerequisites

| Tool                   | Required Version       | Notes                                                                                  |
| :--------------------- | :--------------------- | :------------------------------------------------------------------------------------- |
| **Node.js**            | `v24.x` (`.nvmrc`)     | Verified with `v24.19.0`                                                               |
| **pnpm**               | `12.11.2`              | Strictly forbid `npm` or `yarn`                                                        |
| **PostgreSQL 16+**     | Port `127.0.0.1:5432`  | Uses running local Postgres if active, otherwise Docker Compose (`prism-hub-postgres`) |
| **GNU Make** & **Git** | Standard macOS / Linux | Built-in `make` (`3.81+`) and Git submodules support                                   |

---

## 2. One-Command Bootstrap (`make init`)

From a fresh clone of `prism-hub`:

```bash
git clone https://github.com/thanhba0505/prism-hub.git
cd prism-hub
make init
```

`make init` automatically performs all setup stages:

1. Verifies Node.js, `pnpm`, and Git prerequisites.
2. Runs `git submodule update --init --recursive` and attaches all submodules (`wonderlab`, `central-gateway`, `git-pulse`) to branch `develop`.
3. Copies missing `.env.local` templates from `.env.example` without overwriting existing env files.
4. Ensures PostgreSQL is listening on `127.0.0.1:5432` and creates all 3 databases (`wonderlab`, `central_gateway`, `git_pulse`).
5. Installs workspace dependencies (`pnpm install`) and runs initial local database sync across all 3 services.

---

## 3. Makefile Command Reference

- **Unprefixed commands** (`make <cmd>`) manage shared infrastructure or execute across **all 3 services**.
- **Prefixed commands** (`make <service>-<cmd>`) target only `<service>` (`wonderlab`, `central-gateway`, `git-pulse`), with **`gateway-*`** available as a short alias for `central-gateway-*`.

### Global Commands

| Command                                                 | Action                                                                                         |
| :------------------------------------------------------ | :--------------------------------------------------------------------------------------------- |
| `make help`                                             | Show color-grouped CLI menu (`Wonderlab` Blue, `Central Gateway` Magenta, `Git Pulse` Green)   |
| `make init`                                             | Full first-time workspace initialization                                                       |
| `make status`                                           | Check PostgreSQL connectivity, submodule Git branches/dirtiness, and live ports (`4100..6101`) |
| `make git-sync`                                         | Pull latest `origin/develop` cleanly across all clean submodules                               |
| `make install`                                          | Install dependencies for all 3 monorepos                                                       |
| `make db-up` / `make db-down`                           | Start shared PostgreSQL (`127.0.0.1:5432`) or stop Docker Postgres container                   |
| `make db-reset`                                         | Interactive-confirmation local-only DB reset across all 3 databases                            |
| `make sync-db` / `make db-generate`                     | Sync local Prisma clients & migrations (or regenerate Prisma clients) across all 3 services    |
| `make start`                                            | Start DB + all 6 dev apps concurrently (`Ctrl+C` stops all child processes cleanly)            |
| `make start-clients` / `make start-servers`             | Start only all 3 Next.js frontends OR only all 3 NestJS backends                               |
| `make stop`                                             | Terminate listeners occupying dev ports `4100,4101,5100,5101,6100,6101`                        |
| `make check`                                            | Execute full `pnpm check` sequentially across all 3 repositories                               |
| `make lint` / `typecheck` / `test` / `build` / `format` | Run target script across all 3 repositories                                                    |
| `make clean`                                            | Delete `client/.next` and `server/dist` caches across all 3 repositories                       |

### Per-Service Commands (`<svc>` = `wonderlab` | `central-gateway` | `gateway` | `git-pulse`)

| Command                                                                             | Action                                                                                           |
| :---------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------- |
| `make <svc>-start`                                                                  | Run `make db-up` + `pnpm dev` (both client and server)                                           |
| `make <svc>-start-client` / `<svc>-start-server`                                    | Run only the Next.js frontend or NestJS backend                                                  |
| `make <svc>-stop`                                                                   | Free only `<svc>` dev ports                                                                      |
| `make <svc>-sync-db`                                                                | Verify local DB (`check-local-db.sh`) -> `db:generate` -> `db:migrate:deploy` (+ seed if fresh)  |
| `make <svc>-migrate [NAME=...]`                                                     | Verify local DB -> run `prisma migrate dev` after editing `schema.prisma`                        |
| `make <svc>-seed` / `<svc>-studio`                                                  | Verify local DB -> run `db:seed` or open Prisma Studio                                           |
| `make <svc>-db-generate`                                                            | Regenerate Prisma Client without touching the database                                           |
| `make <svc>-check`                                                                  | Run full verification suite (`format:check`, `lint`, `typecheck`, `test`, [`test:e2e`], `build`) |
| `make <svc>-test-e2e`                                                               | (`wonderlab` only) Verify local DB + execute Supertest E2E suite                                 |
| `make <svc>-lint` / `typecheck` / `test` / `build` / `format` / `install` / `clean` | Run targeted maintenance or build checks inside `services/<svc>`                                 |

---

## 4. Dev Server Safety Standard (`pnpm dev` Only)

> [!CAUTION]
> **STRICTLY FORBID running `pnpm start` or `next start` for local development.**

- Always start development frontends via `make <svc>-start` / `make <svc>-start-client` (`next dev`).
- Running `next start` pins Next.js to an in-memory production `BUILD_ID`. Any concurrent `make check` or `pnpm build` rewrites `.next/` on disk, causing `400 Bad Request` asset lockouts and unstyled pages.
- `next dev` recompiles cleanly on demand and avoids build-ID desynchronization.
