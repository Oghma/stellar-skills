#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: read_contract.sh <contract-id-or-alias> [symbol-key] [output] [durability]

Defaults:
  symbol-key:  omitted
  output:      string
  durability:  persistent
USAGE
}

if [[ $# -gt 4 ]]; then
  usage
  exit 1
fi

contract_id="${1:-}"
symbol_key="${2:-}"
output_format="${3:-string}"
durability="${4:-persistent}"

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

cmd=(stellar contract read --output "$output_format" --durability "$durability")

if [[ -n "$contract_id" ]]; then
  cmd+=(--id "$contract_id")
fi
if [[ -n "$symbol_key" ]]; then
  cmd+=(--key "$symbol_key")
fi
if [[ -n "${NETWORK:-}" ]]; then
  cmd+=(-n "$NETWORK")
fi

echo "Running: ${cmd[*]}"
"${cmd[@]}"
