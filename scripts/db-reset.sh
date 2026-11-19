#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/env-helpers.sh
source "$SCRIPT_DIR/env-helpers.sh"

for svc in "${ALL_SERVICES[@]}"; do
  "$SCRIPT_DIR/check-local-db.sh" "$svc"
done

printf "%b[WARNING]%b This will DROP and RECREATE local databases: wonderlab, central_gateway, git_pulse!\n" \
  "$C_YELLOW" "$C_RESET"
read -r -p "Type 'reset-local-db' to confirm: " confirm
if [[ "$confirm" != "reset-local-db" ]]; then
  printf "%b[ABORTED]%b Local database reset cancelled.\n" "$C_DIM" "$C_RESET"
  exit 1
fi

PG_HOST="127.0.0.1"
PG_PORT="${POSTGRES_PORT:-5432}"
PG_USER="${POSTGRES_USER:-postgres}"

for db in wonderlab central_gateway git_pulse; do
  psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d postgres -c \
    "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$db' AND pid <> pg_backend_pid();" >/dev/null
  psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d postgres -c "DROP DATABASE IF EXISTS \"$db\";" >/dev/null
  psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d postgres -c "CREATE DATABASE \"$db\";" >/dev/null
  printf "  %b✓%b Recreated %s\n" "$C_GREEN" "$C_RESET" "$db"
done

for svc in "${ALL_SERVICES[@]}"; do
  "$SCRIPT_DIR/db-run.sh" "$svc" sync
done
