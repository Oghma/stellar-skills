#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: encode_tx.sh [json-file]

Environment:
  OUTPUT_FORMAT=<single-base64|single>
USAGE
}

if [[ $# -gt 1 ]]; then
  usage
  exit 1
fi

input_value="${1:-}"
output_format="${OUTPUT_FORMAT:-single-base64}"

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

cmd=(stellar tx encode --input json --output "$output_format")

if [[ -n "$input_value" ]]; then
  cmd+=("$input_value")
fi

echo "Running: ${cmd[*]}"
"${cmd[@]}"
