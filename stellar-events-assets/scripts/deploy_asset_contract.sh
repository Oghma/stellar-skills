#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: deploy_asset_contract.sh <asset> <source-account> [alias]

Environment:
  NETWORK=<name>                 Optional network alias
  INCLUSION_FEE=<stroops>        Optional inclusion fee
  INSTRUCTION_LEEWAY=<count>     Optional simulation instruction leeway
  BUILD_ONLY=1                   Output XDR without sending
USAGE
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage
  exit 1
fi

asset_name="$1"
source_account="$2"
alias_name="${3:-}"

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

cmd=(stellar contract asset deploy --asset "$asset_name" --source-account "$source_account")

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

echo "Running: ${cmd[*]}"
"${cmd[@]}"
