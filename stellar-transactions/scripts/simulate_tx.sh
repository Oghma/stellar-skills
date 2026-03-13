#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: simulate_tx.sh <source-account> [xdr-or-file]

Environment:
  NETWORK=<name>              Optional network alias
  INCLUSION_FEE=<stroops>     Optional inclusion fee
  INSTRUCTION_LEEWAY=<count>  Optional simulation instruction leeway
USAGE
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

source_account="$1"
xdr_input="${2:-}"

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

cmd=(stellar tx simulate --source-account "$source_account")

if [[ -n "${NETWORK:-}" ]]; then
  cmd+=(-n "$NETWORK")
fi
if [[ -n "${INCLUSION_FEE:-}" ]]; then
  cmd+=(--inclusion-fee "$INCLUSION_FEE")
fi
if [[ -n "${INSTRUCTION_LEEWAY:-}" ]]; then
  cmd+=(--instruction-leeway "$INSTRUCTION_LEEWAY")
fi
if [[ -n "$xdr_input" ]]; then
  cmd+=("$xdr_input")
fi

echo "Running: ${cmd[*]}"
"${cmd[@]}"
