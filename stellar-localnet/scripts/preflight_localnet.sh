#!/usr/bin/env bash
set -euo pipefail

for cmd in stellar docker; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command not found: $cmd" >&2
    exit 1
  fi
done

echo "stellar: $(stellar --version | head -n 1)"
echo "docker:  $(docker --version)"
echo "Localnet preflight checks passed."
