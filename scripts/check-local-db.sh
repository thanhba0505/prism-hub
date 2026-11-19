#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/env-helpers.sh
source "$SCRIPT_DIR/env-helpers.sh"

svc="$(normalize_service "${1:-}")"
svc_path="$(service_dir "$svc")"
db_url="$(resolve_service_database_url "$svc_path")"

if [[ -z "$db_url" ]]; then
  printf "%b[BLOCKED]%b Missing DATABASE_URL for service '%s'. Configure .env/.env.local in %s first.\n" \
    "$C_RED" "$C_RESET" "$svc" "$svc_path" >&2
  exit 1
fi

check_result="$(node -e '
  const raw = process.argv[1];
  let parsed;
  try {
    parsed = new URL(raw);
  } catch {
    console.error("INVALID_URL");
    process.exit(2);
  }
  const host = parsed.hostname.toLowerCase();
  const allowed = new Set(["127.0.0.1", "localhost", "::1"]);
  if (!allowed.has(host)) {
    console.error(`REMOTE_HOST:${host}`);
    process.exit(1);
  }
  const dbName = parsed.pathname.replace(/^\//, "") || "(unknown)";
  console.log(`${host}:${parsed.port || "5432"}/${dbName}`);
' "$db_url" 2>&1)" || {
  status=$?
  printf "%b[SAFETY BLOCK]%b Refusing DB operation for '%s'!\n" "$C_RED" "$C_RESET" "$svc" >&2
  if [[ "$check_result" == REMOTE_HOST:* ]]; then
    remote_host="${check_result#REMOTE_HOST:}"
    printf "  Detected non-local database host: %b%s%b\n" "$C_YELLOW" "$remote_host" "$C_RESET" >&2
    printf "  Production/Neon database migrations or seeds from local terminal are STRICTLY FORBIDDEN.\n" >&2
  else
    printf "  Malformed DATABASE_URL (%s).\n" "$check_result" >&2
  fi
  exit "$status"
}

printf "%b[SAFE DB]%b %s -> %s (local loopback verified)\n" "$C_GREEN" "$C_RESET" "$svc" "$check_result"
