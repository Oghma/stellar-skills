#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: new_contract.sh <project-path> [contract-name] [--overwrite]

Examples:
  new_contract.sh ./hello-workspace
  new_contract.sh ./counter-workspace counter
  new_contract.sh ./counter-workspace counter --overwrite
USAGE
}

if [[ $# -lt 1 || $# -gt 3 ]]; then
  usage
  exit 1
fi

project_path="$1"
contract_name="${2:-hello-world}"
overwrite_flag="${3:-}"

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

cmd=(stellar contract init "$project_path" --name "$contract_name")
if [[ "$overwrite_flag" == "--overwrite" ]]; then
  cmd+=(--overwrite)
elif [[ -n "$overwrite_flag" ]]; then
  echo "Error: unknown option: $overwrite_flag" >&2
  usage
  exit 1
fi

echo "Running: ${cmd[*]}"
"${cmd[@]}"
