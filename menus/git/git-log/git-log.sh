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

log_by_name() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  git log -n 20 --oneline --date=short --pretty=format:"%Cgreen%h%Creset %Cred%ad%Creset %Cblue% %aN%Creset %s"
}

log_by_email() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  git log -n 20 --oneline --date=short --pretty=format:"%Cgreen%h%Creset %Cred%ad%Creset %Cblue% %ae%Creset %s"
}

last_commit() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  git log -1 --pretty=%s
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
