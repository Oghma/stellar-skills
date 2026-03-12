#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: bootstrap_identity.sh <name>

Environment:
  NETWORK=<name>       Optional network alias, e.g. testnet
  FUND=1               Fund after generation when supported
  SECURE_STORE=1       Save in OS secure store
  OVERWRITE=1          Overwrite existing identity
USAGE
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

identity_name="$1"

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

generate_cmd=(stellar keys generate "$identity_name")

if [[ "${SECURE_STORE:-0}" == "1" ]]; then
  generate_cmd+=(--secure-store)
fi
if [[ "${OVERWRITE:-0}" == "1" ]]; then
  generate_cmd+=(--overwrite)
fi
if [[ -n "${NETWORK:-}" ]]; then
  generate_cmd+=(-n "$NETWORK")
fi

echo "Running: ${generate_cmd[*]}"
"${generate_cmd[@]}"

if [[ "${FUND:-0}" == "1" ]]; then
  fund_cmd=(stellar keys fund "$identity_name")
  if [[ -n "${NETWORK:-}" ]]; then
    fund_cmd+=(-n "$NETWORK")
  fi
  echo "Running: ${fund_cmd[*]}"
  "${fund_cmd[@]}"
fi

echo "Public key:"
stellar keys public-key "$identity_name"
