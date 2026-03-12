#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: generate_python_bindings.sh [binding-args...]

This is a thin wrapper around:
  stellar contract bindings python

Examples:
  generate_python_bindings.sh --help
  generate_python_bindings.sh <arguments-supported-by-your-cli>
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

cmd=(stellar contract bindings python "$@")

echo "Running: ${cmd[*]}"
"${cmd[@]}"
