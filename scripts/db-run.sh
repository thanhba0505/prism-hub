#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/env-helpers.sh
source "$SCRIPT_DIR/env-helpers.sh"

svc="$(normalize_service "${1:-}")"
action="${2:-}"
svc_path="$(service_dir "$svc")"
server_pkg="$(service_server_pkg "$svc")"
color="$(service_color "$svc")"

if [[ ! -d "$svc_path/server" ]]; then
  printf "%b[ERROR]%b Service '%s' is not initialized at %s. Run 'make init' first.\n" \
    "$C_RED" "$C_RESET" "$svc" "$svc_path" >&2
  exit 1
fi

is_users_table_empty() {
  local db_url
  db_url="$(resolve_service_database_url "$svc_path")"
  if ! command -v psql >/dev/null 2>&1; then
    return 1
  fi
  local clean_url="${db_url%%\?*}"
  local count
  count="$(psql "$clean_url" -tAc "SELECT COUNT(*) FROM users;" 2>/dev/null | tr -d '[:space:]' || echo "")"
  [[ "$count" == "0" ]]
}

case "$action" in
  generate)
    printf "%b[%s]%b Generating Prisma Client...\n" "$color" "$svc" "$C_RESET"
    load_service_env_cmd "$svc_path" pnpm --filter "$server_pkg" db:generate
    ;;
  sync)
    "$SCRIPT_DIR/check-local-db.sh" "$svc"
    printf "%b[%s]%b Generating Prisma Client & deploying local migrations...\n" "$color" "$svc" "$C_RESET"
    load_service_env_cmd "$svc_path" pnpm --filter "$server_pkg" db:generate
    load_service_env_cmd "$svc_path" pnpm --filter "$server_pkg" db:migrate:deploy
    if is_users_table_empty; then
      printf "%b[%s]%b Fresh database detected (0 users) -> running initial seed...\n" "$color" "$svc" "$C_RESET"
      load_service_env_cmd "$svc_path" pnpm --filter "$server_pkg" db:seed
    else
      printf "%b[%s]%b Schema synced (existing records preserved; run 'make %s-seed' to re-seed explicitly).\n" \
        "$color" "$svc" "$C_RESET" "$svc"
    fi
    ;;
  migrate)
    "$SCRIPT_DIR/check-local-db.sh" "$svc"
    printf "%b[%s]%b Running Prisma migrate dev...\n" "$color" "$svc" "$C_RESET"
    if [[ -n "${NAME:-}" ]]; then
      load_service_env_cmd "$svc_path" pnpm --filter "$server_pkg" exec prisma migrate dev --name "$NAME"
    else
      load_service_env_cmd "$svc_path" pnpm --filter "$server_pkg" exec prisma migrate dev
    fi
    ;;
  seed)
    "$SCRIPT_DIR/check-local-db.sh" "$svc"
    printf "%b[%s]%b Seeding local database...\n" "$color" "$svc" "$C_RESET"
    load_service_env_cmd "$svc_path" pnpm --filter "$server_pkg" db:seed
    ;;
  studio)
    "$SCRIPT_DIR/check-local-db.sh" "$svc"
    printf "%b[%s]%b Opening Prisma Studio (local DB only)...\n" "$color" "$svc" "$C_RESET"
    load_service_env_cmd "$svc_path" pnpm --filter "$server_pkg" exec prisma studio
    ;;
  *)
    printf "%b[ERROR]%b Unknown db-run action '%s'.\n" "$C_RED" "$C_RESET" "$action" >&2
    exit 1
    ;;
esac
