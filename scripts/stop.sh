#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/env-helpers.sh
source "$SCRIPT_DIR/env-helpers.sh"

targets=()
if [[ "$#" -gt 0 ]]; then
  for arg in "$@"; do
    targets+=("$(normalize_service "$arg")")
  done
else
  targets=("${ALL_SERVICES[@]}")
fi

if ! command -v lsof >/dev/null 2>&1; then
  printf "%b[ERROR]%b 'lsof' is required to identify port listeners.\n" "$C_RED" "$C_RESET" >&2
  exit 1
fi

stop_listener_tree() {
  local pid="$1"
  local cur="$pid"
  local to_kill=("$pid")

  # Walk up watcher/runner ancestors (nest --watch, concurrently, pnpm dev, next dev)
  for _ in 1 2 3 4 5; do
    local info ppid cmd
    info="$(ps -p "$cur" -o ppid=,command= 2>/dev/null || true)"
    [[ -z "$info" ]] && break
    ppid="$(awk '{print $1}' <<<"$info")"
    cmd="${info#*"$ppid"}"
    [[ -z "$ppid" || "$ppid" -le 1 ]] && break

    local parent_cmd
    parent_cmd="$(ps -p "$ppid" -o command= 2>/dev/null || true)"
    if grep -Eq "nest(\.js)?\s+start|concurrently|dev:client|dev:server|pnpm.*\bdev\b|dev-all\.mjs" <<<"$parent_cmd"; then
      to_kill+=("$ppid")
      cur="$ppid"
    else
      break
    fi
  done

  for target_pid in "${to_kill[@]}"; do
    kill -TERM "$target_pid" 2>/dev/null || true
  done
}

for svc in "${targets[@]}"; do
  color="$(service_color "$svc")"
  read -r c_port s_port <<<"$(service_ports "$svc")"
  for port in "$c_port" "$s_port"; do
    pids="$(lsof -iTCP:"$port" -sTCP:LISTEN -t 2>/dev/null || true)"
    if [[ -z "$pids" ]]; then
      printf "%b[%s]%b Port %s is already free.\n" "$color" "$svc" "$C_RESET" "$port"
      continue
    fi
    printf "%b[%s]%b Stopping listener on port %s (PID: %s)...\n" \
      "$color" "$svc" "$C_RESET" "$port" "$(echo "$pids" | tr '\n' ' ')"
    while IFS= read -r pid; do
      [[ -n "$pid" ]] && stop_listener_tree "$pid"
    done <<<"$pids"
  done
done
