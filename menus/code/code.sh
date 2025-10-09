#!/usr/bin/env bash
##################################################################################
# Descrição:
# Menu that shows utility functio relativo to code environment
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
dependencies=(docker gum lazydocker)
is_cmd_installed dependencies

docker() {
  show_menu "${MENUS_DIR}/code/docker/docker.yaml"
}

create_lab() {
  show_menu "${MENUS_DIR}/code/create_lab/create_lab.yaml"
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
