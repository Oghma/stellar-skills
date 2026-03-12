#!/usr/bin/env bash
set -euo pipefail

manifest_path="${1:-}"

for cmd in stellar cargo rustc; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command not found: $cmd" >&2
    exit 1
  fi
done

echo "stellar: $(stellar --version | head -n 1)"
echo "cargo:   $(cargo --version)"
echo "rustc:   $(rustc --version)"

if [[ -n "$manifest_path" && ! -f "$manifest_path" ]]; then
  echo "Error: manifest not found: $manifest_path" >&2
  exit 1
fi

echo "Contract preflight checks passed."
