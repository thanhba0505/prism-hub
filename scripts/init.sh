#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/env-helpers.sh
source "$SCRIPT_DIR/env-helpers.sh"

printf "%b=== Prism Hub Workspace Initialization ===%b\n\n" "$C_CYAN" "$C_RESET"

# 1. Verify prerequisites
for tool in node pnpm git; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf "%b[ERROR]%b Missing required tool: %s\n" "$C_RED" "$C_RESET" "$tool" >&2
    exit 1
  fi
done

node_major="$(node -p "process.versions.node.split('.')[0]")"
if [[ "$node_major" -lt 24 ]]; then
  printf "%b[WARNING]%b Detected Node v%s (recommended v24.x).\n" "$C_YELLOW" "$C_RESET" "$(node -v)"
fi

printf "%b[1/5]%b Prerequisites OK (node %s, pnpm %s)\n" "$C_GREEN" "$C_RESET" "$(node -v)" "$(pnpm -v)"

# 2. Initialize submodules and align onto develop branch
printf "%b[2/5]%b Initializing Git submodules & checking out develop...\n" "$C_CYAN" "$C_RESET"
git -C "$ROOT_DIR" submodule update --init --recursive

for svc in "${ALL_SERVICES[@]}"; do
  svc_path="$(service_dir "$svc")"
  color="$(service_color "$svc")"
  if [[ -n "$(git -C "$svc_path" status --porcelain)" ]]; then
    printf "  %b[%s]%b Dirty working tree detected -> keeping current branch (%s)\n" \
      "$color" "$svc" "$C_RESET" "$(git -C "$svc_path" rev-parse --abbrev-ref HEAD)"
  else
    git -C "$svc_path" fetch origin develop --quiet || true
    git -C "$svc_path" checkout develop --quiet 2>/dev/null || git -C "$svc_path" checkout -B develop origin/develop --quiet
    printf "  %b[%s]%b On branch develop\n" "$color" "$svc" "$C_RESET"
  fi
done

# 3. Bootstrap missing local env files from templates
printf "%b[3/5]%b Checking environment templates...\n" "$C_CYAN" "$C_RESET"
bootstrap_env_pair() {
  local svc="$1"
  local dir="$2"
  local target_name="$3"
  local template="$dir/.env.example"
  if [[ ! -f "$template" ]]; then
    return 0
  fi
  if [[ -f "$dir/.env.local" || -f "$dir/.env" ]]; then
    return 0
  fi
  cp "$template" "$dir/$target_name"
  printf "  %b+%b Created %s/%s from .env.example\n" "$C_GREEN" "$C_RESET" "$svc" "$target_name"
}

for svc in "${ALL_SERVICES[@]}"; do
  svc_path="$(service_dir "$svc")"
  bootstrap_env_pair "$svc" "$svc_path" ".env.local"
  bootstrap_env_pair "$svc/client" "$svc_path/client" ".env.local"
  bootstrap_env_pair "$svc/server" "$svc_path/server" ".env.local"
done

# 4. Ensure local PostgreSQL is running with all 3 databases
printf "%b[4/5]%b Ensuring local PostgreSQL databases...\n" "$C_CYAN" "$C_RESET"
"$SCRIPT_DIR/db-up.sh"

# 5. Install dependencies & sync databases across all services
printf "%b[5/5]%b Installing workspace dependencies & syncing local databases...\n" "$C_CYAN" "$C_RESET"
for svc in "${ALL_SERVICES[@]}"; do
  svc_path="$(service_dir "$svc")"
  color="$(service_color "$svc")"
  printf "%b[%s]%b Installing pnpm dependencies...\n" "$color" "$svc" "$C_RESET"
  pnpm --dir "$svc_path" install
  "$SCRIPT_DIR/db-run.sh" "$svc" sync
done

printf "\n%b[DONE]%b Prism Hub is ready! Run %bmake start%b or %bmake help%b.\n" \
  "$C_GREEN" "$C_RESET" "$C_BOLD" "$C_RESET" "$C_BOLD" "$C_RESET"
