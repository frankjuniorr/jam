#!/usr/bin/env bash
##################################################################################
# Descrição:
# Menu that shows some systens functions
#
##################################################################################

# CONFIG
#---------------------------------------------------------------
set -e

# Declare the functions here
#---------------------------------------------------------------

restart() {
  sudo systemctl restart bluetooth.service
}

connect_headphone() {
  local headphone_mac_address="FC:E8:06:8A:2E:F9"
  bluetoothctl connect "$headphone_mac_address"
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
