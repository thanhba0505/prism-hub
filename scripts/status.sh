#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/env-helpers.sh
source "$SCRIPT_DIR/env-helpers.sh"

check_port() {
  local port="$1"
  if command -v lsof >/dev/null 2>&1; then
    lsof -iTCP:"$port" -sTCP:LISTEN -t >/dev/null 2>&1
    return $?
  fi
  node -e '
    const net = require("net");
    const s = net.connect(Number(process.argv[1]), "127.0.0.1", () => { s.end(); process.exit(0); });
    s.on("error", () => process.exit(1));
  ' "$port"
}

printf "%b=== Prism Hub Status ===%b\n\n" "$C_CYAN" "$C_RESET"

if check_port 5432; then
  printf "%bPostgreSQL (127.0.0.1:5432):%b UP\n" "$C_GREEN" "$C_RESET"
else
  printf "%bPostgreSQL (127.0.0.1:5432):%b DOWN\n" "$C_RED" "$C_RESET"
fi

printf "\n%-18s %-14s %-10s %-14s %-14s\n" "Service" "Branch" "Git" "Client Port" "Server Port"
printf "%-18s %-14s %-10s %-14s %-14s\n" "-------" "------" "---" "-----------" "-----------"

for svc in "${ALL_SERVICES[@]}"; do
  svc_path="$(service_dir "$svc")"
  color="$(service_color "$svc")"
  read -r c_port s_port <<<"$(service_ports "$svc")"

  if [[ -e "$svc_path/.git" ]]; then
    branch="$(git -C "$svc_path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"
    dirty_count="$(git -C "$svc_path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "$dirty_count" == "0" ]]; then
      git_state="clean"
    else
      git_state="${dirty_count} dirty"
    fi
  else
    branch="-"
    git_state="missing"
  fi

  if check_port "$c_port"; then c_state="UP ($c_port)"; else c_state="DOWN ($c_port)"; fi
  if check_port "$s_port"; then s_state="UP ($s_port)"; else s_state="DOWN ($s_port)"; fi

  printf "%b%-18s%b %-14s %-10s %-14s %-14s\n" \
    "$color" "$svc" "$C_RESET" "$branch" "$git_state" "$c_state" "$s_state"
done
