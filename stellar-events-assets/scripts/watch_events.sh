#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: watch_events.sh <contract-id> [count] [output]

Environment:
  NETWORK=<name>         Optional network alias
  EVENT_TYPE=<type>      all, contract, or system
  TOPIC_FILTER=<filter>  Optional topic filter string
  START_LEDGER=<ledger>  Optional starting ledger
USAGE
}

if [[ $# -lt 1 || $# -gt 3 ]]; then
  usage
  exit 1
fi

contract_id="$1"
count="${2:-10}"
output_format="${3:-pretty}"

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

cmd=(stellar events --id "$contract_id" --count "$count" --output "$output_format")

if [[ -n "${NETWORK:-}" ]]; then
  cmd+=(-n "$NETWORK")
fi
if [[ -n "${EVENT_TYPE:-}" ]]; then
  cmd+=(--type "$EVENT_TYPE")
fi
if [[ -n "${TOPIC_FILTER:-}" ]]; then
  cmd+=(--topic "$TOPIC_FILTER")
fi
if [[ -n "${START_LEDGER:-}" ]]; then
  cmd+=(--start-ledger "$START_LEDGER")
fi

echo "Running: ${cmd[*]}"
"${cmd[@]}"
