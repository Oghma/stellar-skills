#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: invoke_contract.sh <contract-id-or-alias> <source-account> [send-mode] [-- <fn-and-args...>]

send-mode:
  default  Send only when simulation indicates writes/auth/events
  no       Simulate only
  yes      Always send
USAGE
}

if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi

contract_id="$1"
source_account="$2"
send_mode="${3:-default}"
shift 2

if [[ "${1:-}" != "--" && $# -gt 0 ]]; then
  shift
fi

if [[ "${1:-}" == "--" ]]; then
  shift
fi

case "$send_mode" in
  default|no|yes) ;;
  *)
    echo "Error: send-mode must be default, no, or yes" >&2
    exit 1
    ;;
esac

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

cmd=(stellar contract invoke --id "$contract_id" --source-account "$source_account" --send "$send_mode")

if [[ -n "${NETWORK:-}" ]]; then
  cmd+=(-n "$NETWORK")
fi
if [[ -n "${INCLUSION_FEE:-}" ]]; then
  cmd+=(--inclusion-fee "$INCLUSION_FEE")
fi
if [[ -n "${INSTRUCTION_LEEWAY:-}" ]]; then
  cmd+=(--instruction-leeway "$INSTRUCTION_LEEWAY")
fi

if [[ $# -gt 0 ]]; then
  cmd+=(-- "$@")
fi

echo "Running: ${cmd[*]}"
"${cmd[@]}"
