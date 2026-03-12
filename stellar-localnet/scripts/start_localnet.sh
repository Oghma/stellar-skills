#!/usr/bin/env bash
set -euo pipefail

network_name="${1:-local}"
container_name="${CONTAINER_NAME:-}"
limits="${LIMITS:-}"
protocol_version="${PROTOCOL_VERSION:-}"
image_tag="${IMAGE_TAG_OVERRIDE:-}"

if ! command -v stellar >/dev/null 2>&1; then
  echo "Error: stellar CLI is required." >&2
  exit 1
fi

cmd=(stellar container start "$network_name")

if [[ -n "$container_name" ]]; then
  cmd+=(--name "$container_name")
fi
if [[ -n "$limits" ]]; then
  cmd+=(--limits "$limits")
fi
if [[ -n "$protocol_version" ]]; then
  cmd+=(--protocol-version "$protocol_version")
fi
if [[ -n "$image_tag" ]]; then
  cmd+=(--image-tag-override "$image_tag")
fi
if [[ -n "${DOCKER_HOST:-}" ]]; then
  cmd+=(--docker-host "$DOCKER_HOST")
fi

echo "Running: ${cmd[*]}"
"${cmd[@]}"
