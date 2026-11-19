# Database Architecture & Neon Production Safety

---

## 1. Dual-Environment Strategy

| Environment             | Engine                                                               | Endpoint / Topology                                                                                              | Migration Mechanism                                                                 |
| :---------------------- | :------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------- |
| **Local Development**   | PostgreSQL 16 (Docker `prism-hub-postgres` or native macOS Postgres) | Single instance on loopback `127.0.0.1:5432` hosting 3 isolated DBs: `wonderlab`, `central_gateway`, `git_pulse` | `make <svc>-sync-db` or `make <svc>-migrate` guarded by `scripts/check-local-db.sh` |
| **Production (Vercel)** | Neon Serverless Lakebase PostgreSQL 16 (`us-west-2` AWS Oregon)      | Dedicated database / branch per service with PgBouncer connection pooling (`sslmode=require`)                    | Executed automatically during Release build hooks via `prisma migrate deploy`       |

All schema definitions, migrations, and seeds use **Prisma ORM (v6.19.x)** inside `services/<service>/server/prisma/`.

---

## 2. Local Shared Postgres Setup (`prism-hub/docker-compose.yml`)

Previously each service shipped its own `docker-compose.yml` mapped to `127.0.0.1:5432:5432`, preventing simultaneous local startup. **Prism Hub** replaces those conflicting definitions with one central configuration:

- [`docker-compose.yml`](../../docker-compose.yml): Spins up `prism-hub-postgres` (`postgres:16-alpine`) bound strictly to `127.0.0.1:5432`, persisted in `prism_hub_postgres_data`.
- [`docker/postgres/init-databases.sql`](../../docker/postgres/init-databases.sql): Idempotently creates `wonderlab`, `central_gateway`, and `git_pulse`.
- [`scripts/db-up.sh`](../../scripts/db-up.sh): Smart detection — if native local PostgreSQL (such as Homebrew Postgres on macOS) is already accepting connections on `127.0.0.1:5432`, it skips starting Docker and directly ensures all 3 databases exist; otherwise it boots `prism-hub-postgres` via Docker Compose and waits for health readiness.

### Default Local Connection Strings

```dotenv
# Wonderlab
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/wonderlab?schema=public

# Central Gateway
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/central_gateway?schema=public

# Git Pulse
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/git_pulse?schema=public
```

---

## 3. Production Neon Safety Guardrail (Non-Negotiable)

> [!CAUTION]
> **STRICTLY FORBID running manual or ad-hoc `prisma migrate deploy`, `prisma db push`, `prisma migrate dev`, or `prisma db seed` against any remote Neon / production database from a developer terminal or AI session.**

Every DB-mutating Makefile command (`sync-db`, `migrate`, `seed`, `studio`, `db-reset`, `wonderlab-test-e2e`) first executes [`scripts/check-local-db.sh`](../../scripts/check-local-db.sh), which resolves `DATABASE_URL` across `.env` / `.env.local` and **aborts immediately** with a non-zero exit code if the hostname is anything other than `127.0.0.1`, `localhost`, or `::1`.

---

## 4. Standardized Server Prisma Scripts

Every service server (`services/<service>/server/package.json`) implements uniform `db:*` commands:

- `db:generate` -> `prisma generate`
- `db:migrate` -> `prisma migrate dev`
- `db:migrate:deploy` -> `prisma migrate deploy`
- `db:seed` -> `prisma db seed` (with `"prisma": { "seed": "ts-node prisma/seed.ts" }`)

Note: `make <svc>-sync-db` executes `db:generate` + `db:migrate:deploy` safely and only runs `db:seed` automatically if the `users` table is empty (`0` rows), preventing accidental overwrites of customized local records. Run `make <svc>-seed` explicitly whenever full seed synchronization is intended.
