#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: deploy_contract.sh <wasm-file> <source-account> [alias] [-- <constructor-args...>]

Environment:
  NETWORK=<name>                 Optional network alias
  INCLUSION_FEE=<stroops>        Optional inclusion fee
  INSTRUCTION_LEEWAY=<count>     Optional simulation instruction leeway
  BUILD_ONLY=1                   Output XDR without sending
USAGE
}

if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi

wasm_file="$1"
source_account="$2"
alias_name="${3:-}"
shift 2

if [[ -n "$alias_name" && "${1:-}" != "--" ]]; then
  shift
fi

if [[ "${1:-}" == "--" ]]; then
  shift
fi

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

if [[ ! -f "$wasm_file" ]]; then
  echo "Error: wasm file not found: $wasm_file" >&2
  exit 1
fi

cmd=(stellar contract deploy --wasm "$wasm_file" --source-account "$source_account")

if [[ -n "${NETWORK:-}" ]]; then
  cmd+=(-n "$NETWORK")
fi
if [[ -n "$alias_name" ]]; then
  cmd+=(--alias "$alias_name")
fi
if [[ -n "${INCLUSION_FEE:-}" ]]; then
  cmd+=(--inclusion-fee "$INCLUSION_FEE")
fi
if [[ -n "${INSTRUCTION_LEEWAY:-}" ]]; then
  cmd+=(--instruction-leeway "$INSTRUCTION_LEEWAY")
fi
if [[ "${BUILD_ONLY:-0}" == "1" ]]; then
  cmd+=(--build-only)
fi

if [[ $# -gt 0 ]]; then
  cmd+=(-- "$@")
fi

echo "Running: ${cmd[*]}"
"${cmd[@]}"
