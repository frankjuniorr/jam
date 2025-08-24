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
dependencies=(gum git lazygit)
is_cmd_installed dependencies

# desfaz as modificações do `git status` de "staged" e "not staged". Mantém os "Untracked Files" caso tenha
status_clean() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  git reset --hard
}

# remove all untracked files, is case of you want to clean in repo.
remove_untracked() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  rm -rf $(git ls-files --others --exclude-standard | xargs)
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
