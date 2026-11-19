#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/env-helpers.sh
source "$SCRIPT_DIR/env-helpers.sh"

PG_HOST="127.0.0.1"
PG_PORT="${POSTGRES_PORT:-5432}"
PG_USER="${POSTGRES_USER:-postgres}"

is_pg_ready() {
  if command -v pg_isready >/dev/null 2>&1; then
    pg_isready -h "$PG_HOST" -p "$PG_PORT" >/dev/null 2>&1
    return $?
  fi
  node -e '
    const net = require("net");
    const s = net.connect(Number(process.argv[2]), process.argv[1], () => { s.end(); process.exit(0); });
    s.on("error", () => process.exit(1));
    setTimeout(() => process.exit(1), 1500);
  ' "$PG_HOST" "$PG_PORT"
}

ensure_databases() {
  local dbs=("wonderlab" "central_gateway" "git_pulse")
  if command -v psql >/dev/null 2>&1; then
    for db in "${dbs[@]}"; do
      local exists
      exists="$(psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d postgres -tAc \
        "SELECT 1 FROM pg_database WHERE datname = '$db';" 2>/dev/null || true)"
      if [[ "$exists" != "1" ]]; then
        psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d postgres -c "CREATE DATABASE \"$db\";" >/dev/null
        printf "  %b+%b Created database %b%s%b\n" "$C_GREEN" "$C_RESET" "$C_BOLD" "$db" "$C_RESET"
      fi
    done
    return 0
  fi

  if command -v docker >/dev/null 2>&1 && docker compose -f "$ROOT_DIR/docker-compose.yml" ps --status running 2>/dev/null | grep -q "prism-hub-postgres"; then
    for db in "${dbs[@]}"; do
      local exists
      exists="$(docker exec prism-hub-postgres psql -U "$PG_USER" -d postgres -tAc \
        "SELECT 1 FROM pg_database WHERE datname = '$db';" 2>/dev/null || true)"
      if [[ "$exists" != "1" ]]; then
        docker exec prism-hub-postgres psql -U "$PG_USER" -d postgres -c "CREATE DATABASE \"$db\";" >/dev/null
        printf "  %b+%b Created database %b%s%b\n" "$C_GREEN" "$C_RESET" "$C_BOLD" "$db" "$C_RESET"
      fi
    done
  fi
}

if is_pg_ready; then
  printf "%b[DB READY]%b PostgreSQL is already accepting connections at %s:%s\n" \
    "$C_GREEN" "$C_RESET" "$PG_HOST" "$PG_PORT"
  ensure_databases
  exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
  printf "%b[ERROR]%b PostgreSQL is not running at %s:%s and Docker CLI was not found.\n" \
    "$C_RED" "$C_RESET" "$PG_HOST" "$PG_PORT" >&2
  exit 1
fi

printf "%b[DB UP]%b Starting shared PostgreSQL 16 container (prism-hub-postgres)...\n" "$C_CYAN" "$C_RESET"
docker compose -f "$ROOT_DIR/docker-compose.yml" up -d postgres

retries=30
while ! is_pg_ready; do
  retries=$((retries - 1))
  if [[ "$retries" -le 0 ]]; then
    printf "%b[ERROR]%b Timed out waiting for PostgreSQL at %s:%s.\n" "$C_RED" "$C_RESET" "$PG_HOST" "$PG_PORT" >&2
    exit 1
  fi
  sleep 1
done

ensure_databases
printf "%b[DB READY]%b Shared PostgreSQL ready at %s:%s (wonderlab, central_gateway, git_pulse)\n" \
  "$C_GREEN" "$C_RESET" "$PG_HOST" "$PG_PORT"
