#!/usr/bin/env bash
set -euo pipefail

container_name="${1:-${CONTAINER_NAME:-}}"

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

cmd=(stellar container stop)

if [[ -n "$container_name" ]]; then
  cmd+=("$container_name")
fi

echo "Running: ${cmd[*]}"
"${cmd[@]}"
