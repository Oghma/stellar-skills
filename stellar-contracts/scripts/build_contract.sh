#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: build_contract.sh <manifest-path> [out-dir]

Environment:
  PACKAGE=<name>           Optional package name
  PROFILE=<name>           Optional profile, default release
  OPTIMIZE=1               Optimize build output (default 1)
  FEATURES=<csv-or-space>  Optional cargo features
  NO_DEFAULT_FEATURES=1    Disable default features
USAGE
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

manifest_path="$1"
out_dir="${2:-}"
profile="${PROFILE:-release}"
optimize="${OPTIMIZE:-1}"
package_name="${PACKAGE:-}"
features="${FEATURES:-}"
no_default_features="${NO_DEFAULT_FEATURES:-0}"

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

if [[ ! -f "$manifest_path" ]]; then
  echo "Error: manifest not found: $manifest_path" >&2
  exit 1
fi

cmd=(stellar contract build --manifest-path "$manifest_path" --profile "$profile")

if [[ "$optimize" == "1" ]]; then
  cmd+=(--optimize)
fi
if [[ -n "$package_name" ]]; then
  cmd+=(--package "$package_name")
fi
if [[ -n "$out_dir" ]]; then
  cmd+=(--out-dir "$out_dir")
fi
if [[ -n "$features" ]]; then
  cmd+=(--features "$features")
fi
if [[ "$no_default_features" == "1" ]]; then
  cmd+=(--no-default-features)
fi

echo "Running: ${cmd[*]}"
"${cmd[@]}"
