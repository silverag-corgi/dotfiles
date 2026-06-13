#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${SCRIPT_DIR}/dotfiles"
DRY_RUN=false

read -r -d '' USAGE <<'USAGE' || true
Usage: install.sh [OPTIONS]

Options:
  --dry-run       Show what would be done, do not make changes
  -h, --help      Show this help message and exit

When run with --dry-run the script will print a one-time notice and
will not perform filesystem changes.
USAGE

for arg in "$@"; do
  case "${arg}" in
    -h|--help)
      echo "$USAGE"
      exit 0
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    *)
      echo "unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

if "${DRY_RUN}"; then
  echo "INF: running in dry-run mode — no changes will be made."
fi

run_command() {
  if "${DRY_RUN}"; then
    # echo "DBG: $*"
    return 0
  fi

  "$@"
}

backup_file() {
  local target_path="$1"

  if [[ -e "${target_path}" || -L "${target_path}" ]]; then
    local ts
    ts=$(date +%Y%m%d_%H%M%S)
    local backup_dir="${HOME}/.dotfiles/${ts}"
    local target_filename="$(basename "${target_path}")"
    local backup_path="${backup_dir}/${target_filename}"
    run_command mkdir -p "${backup_dir}"
    run_command mv "${target_path}" "${backup_path}"
    echo "INF: backed up ${target_path} to ${backup_path}."
  fi
}

link_file() {
  local source_path="$1"
  local target_path="$2"

  backup_file "${target_path}"
  run_command ln -sf "${source_path}" "${target_path}"
  echo "INF: linked ${source_path} to ${target_path}."
}

copy_file() {
  local source_path="$1"
  local target_path="$2"

  backup_file "${target_path}"
  run_command cp "${source_path}" "${target_path}"
  echo "INF: copied ${source_path} to ${target_path}."
  echo "INF: you must update ${target_path}."
}

link_file "${DOTFILES_DIR}/.bashrc" "${HOME}/.bashrc"
link_file "${DOTFILES_DIR}/.bash_aliases" "${HOME}/.bash_aliases"
link_file "${DOTFILES_DIR}/.gitconfig" "${HOME}/.gitconfig"
copy_file "${DOTFILES_DIR}/.gitconfig_business.sample" "${DOTFILES_DIR}/.gitconfig_business"
link_file "${DOTFILES_DIR}/.gitconfig_business" "${HOME}/.gitconfig_business"
link_file "${DOTFILES_DIR}/.gitmessage" "${HOME}/.gitmessage"
