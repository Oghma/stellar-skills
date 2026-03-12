#!/usr/bin/env bash
set -euo pipefail

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

echo "stellar: $(stellar --version | head -n 1)"
echo "Events/assets preflight checks passed."
