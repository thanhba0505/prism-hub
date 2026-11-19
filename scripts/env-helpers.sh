#!/usr/bin/env bash
# Shared constants and service metadata helpers for Prism Hub scripts.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ANSI colors (auto-disabled when stdout is not a TTY unless FORCE_COLOR=1)
if [[ -t 1 || "${FORCE_COLOR:-0}" == "1" ]]; then
  C_RESET='\033[0m'
  C_BOLD='\033[1m'
  C_DIM='\033[2m'
  C_RED='\033[1;31m'
  C_GREEN='\033[1;32m'
  C_YELLOW='\033[1;33m'
  C_BLUE='\033[1;34m'
  C_MAGENTA='\033[1;35m'
  C_CYAN='\033[1;36m'
else
  C_RESET='' C_BOLD='' C_DIM='' C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_MAGENTA='' C_CYAN=''
fi

ALL_SERVICES=("wonderlab" "central-gateway" "git-pulse")

normalize_service() {
  case "${1:-}" in
    wonderlab) echo "wonderlab" ;;
    central-gateway|gateway) echo "central-gateway" ;;
    git-pulse) echo "git-pulse" ;;
    *)
      printf "%b[ERROR]%b Unknown service '%s'. Expected one of: wonderlab, central-gateway (gateway), git-pulse.\n" \
        "$C_RED" "$C_RESET" "${1:-}" >&2
      return 1
      ;;
  esac
}

service_dir() {
  local svc
  svc="$(normalize_service "$1")"
  echo "$ROOT_DIR/services/$svc"
}

service_server_pkg() {
  local svc
  svc="$(normalize_service "$1")"
  echo "${svc}-server"
}

service_db_name() {
  local svc
  svc="$(normalize_service "$1")"
  case "$svc" in
    wonderlab) echo "wonderlab" ;;
    central-gateway) echo "central_gateway" ;;
    git-pulse) echo "git_pulse" ;;
  esac
}

service_ports() {
  local svc
  svc="$(normalize_service "$1")"
  case "$svc" in
    wonderlab) echo "4100 4101" ;;
    central-gateway) echo "5100 5101" ;;
    git-pulse) echo "6100 6101" ;;
  esac
}

service_color() {
  local svc
  svc="$(normalize_service "$1")"
  case "$svc" in
    wonderlab) echo "$C_BLUE" ;;
    central-gateway) echo "$C_MAGENTA" ;;
    git-pulse) echo "$C_GREEN" ;;
  esac
}

# Loads service env files in lowest-to-highest precedence order without
# overriding variables already explicitly exported in the calling shell.
load_service_env_cmd() {
  local svc_path="$1"
  shift
  node -e '
    const fs = require("fs");
    const path = require("path");
    const { spawnSync } = require("child_process");

    const svcPath = process.argv[1];
    const [cmd, ...args] = process.argv.slice(2);

    const parseEnvFile = (filePath) => {
      if (!fs.existsSync(filePath)) return {};
      const out = {};
      const lines = fs.readFileSync(filePath, "utf8").split(/\r?\n/);
      for (const rawLine of lines) {
        const line = rawLine.trim();
        if (!line || line.startsWith("#")) continue;
        const cleaned = line.startsWith("export ") ? line.slice(7).trim() : line;
        const eqIdx = cleaned.indexOf("=");
        if (eqIdx <= 0) continue;
        const key = cleaned.slice(0, eqIdx).trim();
        let val = cleaned.slice(eqIdx + 1).trim();
        if (
          (val.startsWith("\"") && val.endsWith("\"")) ||
          (val.startsWith("\x27") && val.endsWith("\x27"))
        ) {
          val = val.slice(1, -1);
        }
        out[key] = val;
      }
      return out;
    };

    const merged = {};
    const candidates = [
      path.join(svcPath, ".env"),
      path.join(svcPath, ".env.local"),
      path.join(svcPath, "server", ".env"),
      path.join(svcPath, "server", ".env.local"),
    ];
    for (const file of candidates) {
      Object.assign(merged, parseEnvFile(file));
    }

    const finalEnv = { ...merged, ...process.env };
    const result = spawnSync(cmd, args, {
      cwd: svcPath,
      env: finalEnv,
      stdio: "inherit",
    });
    process.exit(result.status ?? 1);
  ' "$svc_path" "$@"
}

resolve_service_database_url() {
  local svc_path="$1"
  load_service_env_cmd "$svc_path" node -e 'process.stdout.write(process.env.DATABASE_URL || "");'
}
