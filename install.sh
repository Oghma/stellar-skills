#!/usr/bin/env bash
set -euo pipefail

# ── Resolve skill source ────────────────────────────────────────────
# If running from a local clone, use it directly. Otherwise download.
repo_root=""
tmp_root=""

if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != "bash" ]]; then
  _script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ -d "${_script_dir}/stellar-contracts" ]]; then
    repo_root="$_script_dir"
  fi
fi

if [[ -z "$repo_root" ]]; then
  repo_slug="${STELLAR_SKILLS_REPO:-Oghma/stellar-skills}"
  repo_ref="${STELLAR_SKILLS_REF:-main}"
  archive_url="${STELLAR_SKILLS_ARCHIVE_URL:-https://codeload.github.com/${repo_slug}/tar.gz/${repo_ref}}"

  download_tool=""
  if command -v curl >/dev/null 2>&1; then
    download_tool="curl"
  elif command -v wget >/dev/null 2>&1; then
    download_tool="wget"
  else
    printf 'Error: curl or wget is required to download stellar-skills.\n' >&2
    exit 1
  fi

  if ! command -v tar >/dev/null 2>&1; then
    printf 'Error: tar is required to unpack stellar-skills.\n' >&2
    exit 1
  fi

  tmp_root="$(mktemp -d)"
  trap 'rm -rf "$tmp_root"' EXIT

  archive_path="${tmp_root}/stellar-skills.tar.gz"
  extract_root="${tmp_root}/extract"
  mkdir -p "$extract_root"

  printf 'Downloading stellar-skills (%s@%s)...\n' "$repo_slug" "$repo_ref"
  case "$download_tool" in
    curl) curl -fsSL "$archive_url" -o "$archive_path" ;;
    wget) wget -qO "$archive_path" "$archive_url" ;;
  esac

  tar -xzf "$archive_path" -C "$extract_root"

  repo_root="$(find "$extract_root" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  if [[ -z "$repo_root" || ! -d "$repo_root" ]]; then
    printf 'Error: failed to locate extracted repository contents.\n' >&2
    exit 1
  fi
fi

# ── Skill catalog ───────────────────────────────────────────────────
all_skills=(
  "stellar-contracts"
  "stellar-localnet"
  "stellar-transactions"
  "stellar-events-assets"
)

# ── State ───────────────────────────────────────────────────────────
target=""
scope_codex=""
scope_claude=""
skills_csv=""
on_exists=""
assume_yes=0

# ── Terminal colors ─────────────────────────────────────────────────
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'
  CYAN=$'\033[36m'
  GREEN=$'\033[32m'
  YELLOW=$'\033[33m'
  RED=$'\033[31m'
  RESET=$'\033[0m'
else
  BOLD="" CYAN="" GREEN="" YELLOW="" RED="" RESET=""
fi

info()    { printf '%s\n' "${CYAN}${*}${RESET}"; }
success() { printf '%s\n' "${GREEN}${*}${RESET}"; }
warn()    { printf '%s\n' "${YELLOW}${*}${RESET}"; }
error()   { printf '%s\n' "${RED}${*}${RESET}" >&2; }

is_interactive() {
  [[ -t 0 && "$assume_yes" -eq 0 ]]
}

# ── Usage ───────────────────────────────────────────────────────────
usage() {
  cat <<'USAGE'
Usage: install.sh [options]

Options:
  --target <codex|claude|both|codex,claude>
  --scope-codex <project|user>
  --scope-claude <project|user>
  --skills <all|comma-separated-skill-list>
  --on-exists <replace|skip|abort>
  --yes
  -h, --help

Remote:
  curl -fsSL https://raw.githubusercontent.com/Oghma/stellar-skills/main/install.sh | bash
  curl -fsSL https://raw.githubusercontent.com/Oghma/stellar-skills/main/install.sh | bash -s -- --target codex --skills all --yes

Local:
  bash install.sh
  bash install.sh --target claude --scope-claude project --skills all --on-exists replace --yes

Environment:
  STELLAR_SKILLS_REPO=<owner/repo>       Override repository slug (remote only)
  STELLAR_SKILLS_REF=<git-ref>           Override branch or tag (remote only)
  STELLAR_SKILLS_ARCHIVE_URL=<url>       Override archive URL directly (remote only)
USAGE
}

# ── Banner ──────────────────────────────────────────────────────────
show_banner() {
  is_interactive || return 0
  cat <<EOF
${CYAN}${BOLD}
  _____ _       _ _            ____  _    _ _ _
 / ____| |     | | |          / ___|| | _(_) | |___
 \\___ \\| |_ ___| | | __ _ _ _\\___ \\| |/ / | | / __|
  ___) | __/ _ \\ | |/ _\` | '__|__) |   <| | | \\__ \\
 |____/|\\__\\___/_|_|\\__,_|_| |____/|_|\\_\\_|_|_|___/
${RESET}
EOF
}

# ── Helpers ─────────────────────────────────────────────────────────
join_by() {
  local delimiter="$1"
  shift
  local first=1
  for value in "$@"; do
    if [[ $first -eq 1 ]]; then
      printf '%s' "$value"
      first=0
    else
      printf '%s%s' "$delimiter" "$value"
    fi
  done
}

contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

parse_targets() {
  local raw="$1"
  case "$raw" in
    both)
      printf '%s\n' codex claude
      ;;
    codex|claude)
      printf '%s\n' "$raw"
      ;;
    codex,claude|claude,codex)
      printf '%s\n' codex claude
      ;;
    *)
      error "Error: unsupported target selection: $raw"
      exit 1
      ;;
  esac
}

validate_scope() {
  local name="$1"
  case "$name" in
    project|user) ;;
    *)
      error "Error: scope must be project or user, got: $name"
      exit 1
      ;;
  esac
}

validate_on_exists() {
  local mode="$1"
  case "$mode" in
    replace|skip|abort) ;;
    *)
      error "Error: on-exists must be replace, skip, or abort, got: $mode"
      exit 1
      ;;
  esac
}

prompt_if_empty() {
  local var_name="$1"
  local prompt="$2"
  local default_value="$3"
  local current_value="${!var_name:-}"

  if [[ -n "$current_value" ]]; then
    return 0
  fi

  if [[ "$assume_yes" -eq 1 ]]; then
    printf -v "$var_name" '%s' "$default_value"
    return 0
  fi

  read -r -p "${BOLD}${prompt}${RESET} [${default_value}]: " current_value
  current_value="${current_value:-$default_value}"
  printf -v "$var_name" '%s' "$current_value"
}

resolve_destination() {
  local target_name="$1"
  local scope_name="$2"

  case "$target_name:$scope_name" in
    codex:project) printf '%s/.agents/skills' "$PWD" ;;
    codex:user) printf '%s/.agents/skills' "$HOME" ;;
    claude:project) printf '%s/.claude/skills' "$PWD" ;;
    claude:user) printf '%s/.claude/skills' "$HOME" ;;
    *)
      error "Error: unsupported install destination for ${target_name}:${scope_name}"
      exit 1
      ;;
  esac
}

# ── Read a field from SKILL.md frontmatter ──────────────────────────
get_frontmatter_field() {
  local skill_md="$1"
  local field="$2"
  if [[ -f "$skill_md" ]]; then
    sed -n "s/^${field}: //p" "$skill_md" | head -n 1
  fi
}

get_skill_description() {
  local skill_name="$1"
  get_frontmatter_field "${repo_root}/${skill_name}/SKILL.md" "description" | cut -c1-60
}

# ── Interactive skill selection menu ────────────────────────────────
prompt_skills_menu() {
  local i
  local -a selected=()
  local -a descriptions=()

  for i in "${!all_skills[@]}"; do
    selected+=("1")
    descriptions+=("$(get_skill_description "${all_skills[$i]}")")
  done

  while true; do
    printf '\n%s\n' "${BOLD}Select skills to install (enter number to toggle, a=all, n=none, d=done):${RESET}"
    for i in "${!all_skills[@]}"; do
      local mark
      if [[ "${selected[$i]}" -eq 1 ]]; then
        mark="${GREEN}[x]${RESET}"
      else
        mark="[ ]"
      fi
      printf '  %d) %s %-26s %s\n' "$((i + 1))" "$mark" "${all_skills[$i]}" "${CYAN}${descriptions[$i]}${RESET}"
    done
    printf '> '
    read -r choice

    case "$(printf '%s' "$choice" | tr '[:upper:]' '[:lower:]')" in
      d|"")
        break
        ;;
      a)
        for i in "${!all_skills[@]}"; do selected[$i]=1; done
        ;;
      n)
        for i in "${!all_skills[@]}"; do selected[$i]=0; done
        ;;
      *)
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#all_skills[@]} )); then
          local idx=$((choice - 1))
          if [[ "${selected[$idx]}" -eq 1 ]]; then
            selected[$idx]=0
          else
            selected[$idx]=1
          fi
        fi
        ;;
    esac
  done

  local result=()
  for i in "${!all_skills[@]}"; do
    if [[ "${selected[$i]}" -eq 1 ]]; then
      result+=("${all_skills[$i]}")
    fi
  done

  if [[ ${#result[@]} -eq 0 ]]; then
    error "Error: no skills selected"
    exit 1
  fi

  skills_csv="$(join_by ',' "${result[@]}")"
}

# ── Detect existing installations ──────────────────────────────────
# Returns 0 if existing installations found, 1 otherwise.
detect_existing() {
  local -a targets=("$@")
  local found=0

  for t in "${targets[@]}"; do
    local scope_var="scope_${t}"
    local scope="${!scope_var:-}"
    [[ -z "$scope" ]] && continue

    local dest
    dest="$(resolve_destination "$t" "$scope")"

    for skill in "${all_skills[@]}"; do
      if [[ -d "${dest}/${skill}" ]]; then
        if [[ "$found" -eq 0 ]]; then
          printf '\n'
          info "Existing installations detected:"
          found=1
        fi
        printf '  %-26s -> %s\n' "$skill" "${dest}/${skill}"
      fi
    done
  done

  return $(( found == 0 ))
}

# ── Copy skill ──────────────────────────────────────────────────────
copy_skill() {
  local skill_name="$1"
  local destination_root="$2"
  local destination_path="${destination_root}/${skill_name}"
  local source_path="${repo_root}/${skill_name}"

  if [[ ! -d "$source_path" ]]; then
    error "Error: skill directory not found: $source_path"
    exit 1
  fi

  mkdir -p "$destination_root"

  if [[ -e "$destination_path" ]]; then
    case "$on_exists" in
      replace)
        rm -rf "$destination_path"
        ;;
      skip)
        warn "  ~ ${skill_name} (skipped, already exists)"
        return 1
        ;;
      abort)
        error "Aborting because destination exists: $destination_path"
        exit 1
        ;;
    esac
  fi

  success "  + ${skill_name}"
  cp -R "$source_path" "$destination_path"
}

# ── Sanity check ────────────────────────────────────────────────────
run_sanity_check() {
  local destination_root="$1"
  shift

  local skill_name
  for skill_name in "$@"; do
    local skill_md="${destination_root}/${skill_name}/SKILL.md"
    if [[ ! -f "$skill_md" ]]; then
      error "Error: missing SKILL.md after install: ${destination_root}/${skill_name}"
      exit 1
    fi

    local declared_name
    declared_name="$(get_frontmatter_field "$skill_md" "name")"
    if [[ "$declared_name" != "$skill_name" ]]; then
      error "Error: name mismatch after install: ${skill_md} declares '${declared_name}'"
      exit 1
    fi
  done
}

# ── Parse CLI arguments ────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      target="${2:-}"
      shift 2
      ;;
    --scope-codex)
      scope_codex="${2:-}"
      shift 2
      ;;
    --scope-claude)
      scope_claude="${2:-}"
      shift 2
      ;;
    --skills)
      skills_csv="${2:-}"
      shift 2
      ;;
    --on-exists)
      on_exists="${2:-}"
      shift 2
      ;;
    --yes)
      assume_yes=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Error: unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# ── Interactive flow ────────────────────────────────────────────────
show_banner

prompt_if_empty target "Install target(s): codex, claude, or both" "codex"

selected_targets=()
while IFS= read -r parsed_target; do
  selected_targets+=("$parsed_target")
done < <(parse_targets "$target")

for t in "${selected_targets[@]}"; do
  scope_var="scope_${t}"
  prompt_if_empty "$scope_var" "${t} scope: project or user" "project"
  validate_scope "${!scope_var}"
done

# Detect existing installations and conditionally prompt on-exists
if [[ -z "$skills_csv" ]]; then
  if is_interactive; then
    prompt_skills_menu
  else
    skills_csv="all"
  fi
fi

if detect_existing "${selected_targets[@]}"; then
  info "Re-running will update these based on your on-exists policy."
  prompt_if_empty on_exists "If destination exists: replace, skip, or abort" "replace"
else
  on_exists="${on_exists:-replace}"
fi
validate_on_exists "$on_exists"

# ── Resolve selected skills ────────────────────────────────────────
declare -a selected_skills=()

if [[ "$skills_csv" == "all" ]]; then
  selected_skills=("${all_skills[@]}")
else
  IFS=',' read -r -a raw_skills <<<"$skills_csv"
  for raw_skill in "${raw_skills[@]}"; do
    skill="${raw_skill//[[:space:]]/}"
    if ! contains "$skill" "${all_skills[@]}"; then
      error "Error: unknown skill: $skill"
      exit 1
    fi
    selected_skills+=("$skill")
  done
fi

if [[ ${#selected_skills[@]} -eq 0 ]]; then
  error "Error: no skills selected"
  exit 1
fi

# ── Resolve destinations once ──────────────────────────────────────
dest_codex=""
dest_claude=""
for selected_target in "${selected_targets[@]}"; do
  case "$selected_target" in
    codex)  dest_codex="$(resolve_destination codex "$scope_codex")" ;;
    claude) dest_claude="$(resolve_destination claude "$scope_claude")" ;;
  esac
done

# ── Confirmation prompt ────────────────────────────────────────────
printf '\n'
info "${BOLD}Install summary${RESET}"
printf '  targets: %s\n' "$(join_by ', ' "${selected_targets[@]}")"
printf '  skills:  %s\n' "$(join_by ', ' "${selected_skills[@]}")"
printf '  mode:    %s\n' "${on_exists}"
for selected_target in "${selected_targets[@]}"; do
  case "$selected_target" in
    codex)  printf '  %s path: %s\n' "$selected_target" "$dest_codex" ;;
    claude) printf '  %s path: %s\n' "$selected_target" "$dest_claude" ;;
  esac
done

if is_interactive; then
  printf '\n'
  read -r -p "${BOLD}Proceed with installation?${RESET} [Y/n]: " confirm
  case "$(printf '%s' "$confirm" | tr '[:upper:]' '[:lower:]')" in
    n|no)
      info "Installation cancelled."
      exit 0
      ;;
  esac
fi

# ── Install ─────────────────────────────────────────────────────────
printf '\n'
declare -a actually_installed=()

for selected_target in "${selected_targets[@]}"; do
  case "$selected_target" in
    codex)  destination_root="$dest_codex" ;;
    claude) destination_root="$dest_claude" ;;
  esac

  info "Installing to ${destination_root}"
  local_installed=()
  for skill_name in "${selected_skills[@]}"; do
    if copy_skill "$skill_name" "$destination_root"; then
      local_installed+=("$skill_name")
      if [[ ${#actually_installed[@]} -eq 0 ]] || ! contains "$skill_name" "${actually_installed[@]}"; then
        actually_installed+=("$skill_name")
      fi
    fi
  done

  if [[ ${#local_installed[@]} -gt 0 ]]; then
    run_sanity_check "$destination_root" "${local_installed[@]}"
  fi
done

# ── Post-install message ────────────────────────────────────────────
printf '\n'
success "${BOLD}Installation complete!${RESET}"
printf '\n'
if [[ ${#actually_installed[@]} -gt 0 ]]; then
  printf 'Installed skills:\n'
  for skill_name in "${actually_installed[@]}"; do
    success "  + ${skill_name}"
  done
else
  info "No new skills installed (all skipped)."
fi
printf '\n'
printf "What's next:\n"
for selected_target in "${selected_targets[@]}"; do
  case "$selected_target" in
    codex)  printf '  - Start Codex in this directory to use the skills\n' ;;
    claude) printf '  - Start Claude Code in this directory to use the skills\n' ;;
  esac
done
printf '\n'
printf 'To update skills later, re-run:\n'
printf '  curl -fsSL https://raw.githubusercontent.com/Oghma/stellar-skills/main/install.sh | bash\n'
