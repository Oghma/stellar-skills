#!/usr/bin/env bash
set -euo pipefail

repo_slug="${STELLAR_SKILLS_REPO:-Oghma/stellar-skills}"
repo_ref="${STELLAR_SKILLS_REF:-main}"
archive_url="${STELLAR_SKILLS_ARCHIVE_URL:-https://codeload.github.com/${repo_slug}/tar.gz/${repo_ref}}"

# ── Terminal colors ──────────────────────────────────────────────────
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'
  CYAN=$'\033[36m'
  GREEN=$'\033[32m'
  RED=$'\033[31m'
  RESET=$'\033[0m'
else
  BOLD="" CYAN="" GREEN="" RED="" RESET=""
fi

info()  { printf '%s\n' "${CYAN}${*}${RESET}"; }
error() { printf '%s\n' "${RED}${*}${RESET}" >&2; }

usage() {
  cat <<'USAGE' >&2
Usage: curl -fsSL https://raw.githubusercontent.com/Oghma/stellar-skills/main/install.sh | bash [-- installer-args...]

Environment:
  STELLAR_SKILLS_REPO=<owner/repo>       Override repository slug
  STELLAR_SKILLS_REF=<git-ref>           Override branch or tag to download
  STELLAR_SKILLS_ARCHIVE_URL=<url>       Override archive download URL directly

Examples:
  curl -fsSL https://raw.githubusercontent.com/Oghma/stellar-skills/main/install.sh | bash
  curl -fsSL https://raw.githubusercontent.com/Oghma/stellar-skills/main/install.sh | bash -s -- --target codex --scope-codex project --skills all --on-exists replace --yes
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

download_tool=""
if command -v curl >/dev/null 2>&1; then
  download_tool="curl"
elif command -v wget >/dev/null 2>&1; then
  download_tool="wget"
else
  error "Error: curl or wget is required to download stellar-skills."
  exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
  error "Error: tar is required to unpack stellar-skills."
  exit 1
fi

tmp_root="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_root"
}
trap cleanup EXIT

archive_path="${tmp_root}/stellar-skills.tar.gz"
extract_root="${tmp_root}/extract"
mkdir -p "$extract_root"

info "Downloading stellar-skills (${repo_slug}@${repo_ref})..."
case "$download_tool" in
  curl)
    curl -fsSL "$archive_url" -o "$archive_path"
    ;;
  wget)
    wget -qO "$archive_path" "$archive_url"
    ;;
esac

tar -xzf "$archive_path" -C "$extract_root"

repo_root="$(find "$extract_root" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
if [[ -z "$repo_root" || ! -d "$repo_root" ]]; then
  error "Error: failed to locate extracted repository contents."
  exit 1
fi

installer="${repo_root}/bin/install-stellar-skills.sh"
if [[ ! -f "$installer" ]]; then
  error "Error: installer not found in downloaded archive: ${installer}"
  exit 1
fi

info "Starting installer..."
printf '\n'
bash "$installer" "$@"
