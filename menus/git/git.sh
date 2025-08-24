#!/usr/bin/env bash
##################################################################################
# Descrição:
# Menu that shows utility functio relativo to Git
#
##################################################################################

# CONFIG
# -----------------------------------------------------------------------
set -e
set -u

# Import dependencies
#---------------------------------------------------------------
source "${SCRIPT_ROOT_DIR}/core/control.sh"

# check dependencies
dependencies=(git lazygit)
is_cmd_installed dependencies

git_branch() {
  show_menu "${MENUS_DIR}/git/git-branch/git-branch.yaml"
}

git_commit() {
  show_menu "${MENUS_DIR}/git/git-commit/git-commit.yaml"
}

git_log() {
  show_menu "${MENUS_DIR}/git/git-log/git-log.yaml"
}

git_repository() {
  show_menu "${MENUS_DIR}/git/git-repository/git-repository.yaml"
}

git_status() {
  show_menu "${MENUS_DIR}/git/git-status/git-status.yaml"
}

git_tags() {
  show_menu "${MENUS_DIR}/git/git-tags/git-tags.yaml"
}

git_tui() {
  lazygit
}

################################################################
# MAIN
################################################################

# Execute a function if passed as argument
function_name="$1"

if [[ -n "$function_name" ]]; then
  "$function_name"
  exit "$?"
fi
