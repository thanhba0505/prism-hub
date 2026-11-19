#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/env-helpers.sh
source "$SCRIPT_DIR/env-helpers.sh"

for svc in "${ALL_SERVICES[@]}"; do
  svc_path="$(service_dir "$svc")"
  color="$(service_color "$svc")"
  if [[ ! -e "$svc_path/.git" ]]; then
    printf "%b[%s]%b Not initialized yet -> skipping.\n" "$C_YELLOW" "$svc" "$C_RESET"
    continue
  fi

  if [[ -n "$(git -C "$svc_path" status --porcelain)" ]]; then
    printf "%b[%s]%b Dirty working tree -> skipping pull to protect local changes.\n" \
      "$C_YELLOW" "$svc" "$C_RESET"
    continue
  fi

  printf "%b[%s]%b Pulling latest origin/develop...\n" "$color" "$svc" "$C_RESET"
  git -C "$svc_path" fetch origin develop
  git -C "$svc_path" checkout develop --quiet 2>/dev/null || git -C "$svc_path" checkout -B develop origin/develop --quiet
  git -C "$svc_path" pull --ff-only origin develop
done
