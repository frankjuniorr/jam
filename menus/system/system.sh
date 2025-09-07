#!/usr/bin/env bash
##################################################################################
# Descrição:
# Menu that shows utility function relativo to my system
#
##################################################################################

# CONFIG
# -----------------------------------------------------------------------
set -e
set -u

# Import dependencies
#---------------------------------------------------------------
source "${SCRIPT_ROOT_DIR}/core/control.sh"

# Internal functions
#---------------------------------------------------------------
__ubuntu_upgrade() {
  figlet "Ubuntu"
  echo "Update..."
  sudo apt update

  echo "Upgrade..."
  sudo apt upgrade -y
  sudo apt dist-upgrade -y

  echo "Resolvendo pacotes quebrados..."
  sudo apt -f -y install

  echo "limpando o repositório local..."
  sudo apt autoremove -y
  sudo apt autoclean -y
  sudo apt clean -y
}

__neovim_upgrade() {
  nvim --headless "+Lazy! sync" +qa
}

__arch_upgrade() {
  figlet "Neovim"
  __neovim_upgrade

  figlet "Arch"
  echo "==> Atualizando o sistema..."
  sudo pacman -Syu --noconfirm
  yay -Syu --noconfirm

  echo "==> Limpando o cache do yay..."
  yay -Sc --noconfirm
}

# Menu funtions
#---------------------------------------------------------------
bluetooth() {
  show_menu "${MENUS_DIR}/system/bluetooth/bluetooth.yaml"
}

upgrade() {
  OS=$(grep "^ID=" /etc/os-release | cut -d "=" -f2)

  case $OS in
  ubuntu) __ubuntu_upgrade ;;
  arch) __arch_upgrade ;;
  *)
    echo "❌ Unsupported OS"
    echo "values supporteds: 'ubuntu' 'arch'"
    exit 1
    ;;
  esac
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
