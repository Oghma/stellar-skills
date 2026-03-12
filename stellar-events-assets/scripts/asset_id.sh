#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: asset_id.sh <asset>

Examples:
  asset_id.sh native
  asset_id.sh USDC:G...
USAGE
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

asset_name="$1"

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

cmd=(stellar contract id asset --asset "$asset_name")

if [[ -n "${NETWORK:-}" ]]; then
  cmd+=(-n "$NETWORK")
fi

echo "Running: ${cmd[*]}"
"${cmd[@]}"
