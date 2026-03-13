#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: decode_tx.sh [xdr-or-file]

Environment:
  INPUT_FORMAT=<single-base64|single>
  OUTPUT_FORMAT=<json|json-formatted>
USAGE
}

if [[ $# -gt 1 ]]; then
  usage
  exit 1
fi

input_value="${1:-}"
input_format="${INPUT_FORMAT:-single-base64}"
output_format="${OUTPUT_FORMAT:-json-formatted}"

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

cmd=(stellar tx decode --input "$input_format" --output "$output_format")

if [[ -n "$input_value" ]]; then
  cmd+=("$input_value")
fi

echo "Running: ${cmd[*]}"
"${cmd[@]}"
