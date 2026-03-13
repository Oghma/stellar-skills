#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

skills=(
  "stellar-contracts"
  "stellar-localnet"
  "stellar-transactions"
  "stellar-events-assets"
)

for root_file in README.md STANDARD_SKILL_SPEC.md install.sh; do
  if [[ ! -f "${repo_root}/${root_file}" ]]; then
    echo "Error: missing required root file: ${root_file}" >&2
    exit 1
  fi
done

for skill in "${skills[@]}"; do
  skill_dir="${repo_root}/${skill}"

  for required in SKILL.md reference.md patterns.md; do
    if [[ ! -f "${skill_dir}/${required}" ]]; then
      echo "Error: missing ${required} in ${skill}" >&2
      exit 1
    fi
  done

  if [[ ! -d "${skill_dir}/scripts" ]]; then
    echo "Error: missing scripts directory in ${skill}" >&2
    exit 1
  fi

  declared_name="$(sed -n 's/^name: //p' "${skill_dir}/SKILL.md" | head -n 1)"
  if [[ "${declared_name}" != "${skill}" ]]; then
    echo "Error: skill ${skill} declares name '${declared_name}'" >&2
    exit 1
  fi

  while IFS= read -r script_path; do
    if [[ ! -x "${script_path}" ]]; then
      echo "Error: script is not executable: ${script_path}" >&2
      exit 1
    fi
  done < <(find "${skill_dir}/scripts" -type f | sort)
done

echo "Packaged contents look valid."
