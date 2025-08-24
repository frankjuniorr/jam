#!/usr/bin/env bash
##################################################################################
# Descrição:
# Menu that shows utility function Python
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
dependencies=(python3)
is_cmd_installed dependencies

# ----------------------------------------------------------------------
# alias rápido que habilita um venv padrão no python
enable_venv() {

  os_name=$(grep "^NAME=" /etc/os-release | cut -d '=' -f2 | sed 's/"//g')

  case $os_name in
  "Ubuntu")
    if ! dpkg -s python3-venv >/dev/null 2>&1; then
      echo "⚠️  Package 'python3-venv' is not installed."
      echo "   Install it with:"
      echo "   sudo apt install python3-venv"
      return 1
    fi
    ;;
  "Arch Linux")
    if ! pacman -Qi python-virtualenv >/dev/null 2>&1; then
      echo "⚠️  Package 'python-virtualenv' is not installed."
      echo "   Install it with:"
      echo "   sudo pacman -S python-virtualenv"
      return 1
    fi
    ;;
  esac

  python3 -m venv .venv
  source venv/bin/activate
}
disable_venv() {
  deactivate
}

open_shell() {
  python3
}

zen() {
  python3 -c "import this"
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
