#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
installer="${repo_root}/install.sh"

pass_count=0
fail_count=0

run_test() {
  local name="$1"
  shift
  echo "─── Test: ${name} ───"
  if "$@"; then
    echo "  PASS: ${name}"
    ((pass_count++))
  else
    echo "  FAIL: ${name}" >&2
    ((fail_count++))
  fi
  echo ""
}

assert_file_exists() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "  Expected file missing: ${path}" >&2
    return 1
  fi
}

assert_dir_exists() {
  local path="$1"
  if [[ ! -d "$path" ]]; then
    echo "  Expected directory missing: ${path}" >&2
    return 1
  fi
}

# ── 1. codex:project, all skills, replace ────────────────────────────
test_codex_project_all() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '${tmp}'" RETURN

  ( cd "$tmp" && bash "$installer" \
      --target codex --scope-codex project \
      --skills all --on-exists replace --yes )

  for skill in stellar-contracts stellar-localnet stellar-transactions stellar-events-assets; do
    assert_file_exists "${tmp}/.agents/skills/${skill}/SKILL.md"
  done
}
run_test "codex:project, all skills, replace" test_codex_project_all

# ── 2. claude:project, all skills, replace ───────────────────────────
test_claude_project_all() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '${tmp}'" RETURN

  ( cd "$tmp" && bash "$installer" \
      --target claude --scope-claude project \
      --skills all --on-exists replace --yes )

  for skill in stellar-contracts stellar-localnet stellar-transactions stellar-events-assets; do
    assert_file_exists "${tmp}/.claude/skills/${skill}/SKILL.md"
  done
}
run_test "claude:project, all skills, replace" test_claude_project_all

# ── 3. codex:user (with HOME override) ──────────────────────────────
test_codex_user() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '${tmp}'" RETURN

  ( HOME="$tmp" bash "$installer" \
      --target codex --scope-codex user \
      --skills stellar-contracts --on-exists replace --yes )

  assert_file_exists "${tmp}/.agents/skills/stellar-contracts/SKILL.md"
}
run_test "codex:user (HOME override)" test_codex_user

# ── 4. target both, project scope ───────────────────────────────────
test_both_project() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '${tmp}'" RETURN

  ( cd "$tmp" && bash "$installer" \
      --target both --scope-codex project --scope-claude project \
      --skills stellar-contracts,stellar-localnet --on-exists replace --yes )

  assert_file_exists "${tmp}/.agents/skills/stellar-contracts/SKILL.md"
  assert_file_exists "${tmp}/.agents/skills/stellar-localnet/SKILL.md"
  assert_file_exists "${tmp}/.claude/skills/stellar-contracts/SKILL.md"
  assert_file_exists "${tmp}/.claude/skills/stellar-localnet/SKILL.md"
}
run_test "target both, project scope" test_both_project

# ── 5. on-exists skip ───────────────────────────────────────────────
test_on_exists_skip() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '${tmp}'" RETURN

  local dest="${tmp}/.agents/skills/stellar-contracts"
  mkdir -p "$dest"
  echo "original" > "${dest}/SKILL.md"

  ( cd "$tmp" && bash "$installer" \
      --target codex --scope-codex project \
      --skills stellar-contracts --on-exists skip --yes )

  local content
  content="$(cat "${dest}/SKILL.md")"
  if [[ "$content" != "original" ]]; then
    echo "  Expected SKILL.md to be untouched (skip), but it was overwritten" >&2
    return 1
  fi
}
run_test "on-exists skip" test_on_exists_skip

# ── 6. Re-run / update (replace on existing) ────────────────────────
test_rerun_replace() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '${tmp}'" RETURN

  # First install
  ( cd "$tmp" && bash "$installer" \
      --target codex --scope-codex project \
      --skills stellar-contracts --on-exists replace --yes )

  assert_file_exists "${tmp}/.agents/skills/stellar-contracts/SKILL.md"

  # Second install (update)
  ( cd "$tmp" && bash "$installer" \
      --target codex --scope-codex project \
      --skills stellar-contracts,stellar-localnet --on-exists replace --yes )

  assert_file_exists "${tmp}/.agents/skills/stellar-contracts/SKILL.md"
  assert_file_exists "${tmp}/.agents/skills/stellar-localnet/SKILL.md"
}
run_test "re-run / update (replace)" test_rerun_replace

# ── Summary ──────────────────────────────────────────────────────────
echo "═══════════════════════════════════════"
echo "  Passed: ${pass_count}  Failed: ${fail_count}"
echo "═══════════════════════════════════════"

if [[ "$fail_count" -gt 0 ]]; then
  exit 1
fi

echo "Installer smoke test passed."
