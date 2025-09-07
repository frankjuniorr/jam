#!/usr/bin/env bash
##################################################################################
# Descrição:
# Menu that shows utility function relativo to navigate on the file system
#
##################################################################################

# CONFIG
# -----------------------------------------------------------------------
set -e
set -u

# Import dependencies
#---------------------------------------------------------------
source "${SCRIPT_ROOT_DIR}/core/control.sh"

# Menu funtions
#---------------------------------------------------------------
find_files() {

  dependencies=(bat fd)
  is_cmd_installed dependencies

  local max_depth=10
  local preview_cmd='bat --color always --style=plain  {}'
  local list_files=($(fd --max-depth "$max_depth" --type file))

  local selected_file=$(create_generic_fzf_menu list_files "Find Files" "false" "$preview_cmd")

  if [[ -n "$selected_file" ]]; then
    nvim "$selected_file"
  else
    echo "No file selected or search returned no results."
  fi
}

search_string() {

  dependencies=(rg fd)
  is_cmd_installed dependencies

  param=$(gum input --cursor.foreground=2 --no-show-help --placeholder="Qual string você está procurando?")
  test -z "$param" && echo "Empty search" && exit 0

  preview_cmd="rg -i --line-number --color=always \"$param\" {}"
  IFS=$'\n' search_string_on_files=($(rg -il "$param" ./))
  unset IFS

  local selected_file=$(create_generic_fzf_menu search_string_on_files "Search String" "false" "$preview_cmd")

  if [[ -n "$selected_file" ]]; then
    local line_number=$(rg -i -n -m 1 "$param" "$selected_file" | cut -d ":" -f1)
    nvim "+${line_number}" "$selected_file"
  else
    echo "No file selected or search returned no results."
  fi
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
