#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: send_tx.sh [xdr-or-file]

Environment:
  NETWORK=<name>  Optional network alias
USAGE
}

if [[ $# -gt 1 ]]; then
  usage
  exit 1
fi

xdr_input="${1:-}"

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

cmd=(stellar tx send)

if [[ -n "${NETWORK:-}" ]]; then
  cmd+=(-n "$NETWORK")
fi
if [[ -n "$xdr_input" ]]; then
  cmd+=("$xdr_input")
fi

echo "Running: ${cmd[*]}"
"${cmd[@]}"
