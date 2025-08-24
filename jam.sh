#!/usr/bin/env bash
#########################################################################
# Description:
#   Main application file, it is the primary entry point.
#   This file displays a main menu using `fzf`, with a list of all other available menus,
#   dynamically reading from each menu’s `.yaml` file.
#
# Parameters
#   - Yaml file: If you want to call a specific menu directly, pass the path of that menu’s `.yaml` file as a parameter.
#       Otherwise, all available menus will be displayed by default.
#########################################################################

# CONFIG
# -----------------------------------------------------------------------
set -e

export APP_NAME="$(basename "${BASH_SOURCE[0]}" ".sh")"
export SCRIPT_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CORE_DIR="${CORE_DIR:-$SCRIPT_ROOT_DIR/core}"

export MENUS_DIR="$SCRIPT_ROOT_DIR/menus"
if [ ! -d "$MENUS_DIR" ]; then
  export MENUS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/${APP_NAME}/menus"
fi

# Import the core functionality
# -----------------------------------------------------------------------
source "$CORE_DIR/control.sh"

# check dependencies
# -----------------------------------------------------------------------
dependencies=(fzf figlet glow gum yq fd)
is_cmd_installed dependencies

# Check parameter: yaml file
# -----------------------------------------------------------------------
yaml_file="$1"

# If an argument is provided, execute that menu directly
if [[ -n "$yaml_file" ]]; then

  if [[ ! -f "$yaml_file" ]]; then
    echo "Menu '$yaml_file' not found"
    exit 1
  fi

  # get only the filename from absolute path `$yaml_file`
  filename=$(basename -- "$yaml_file")

  # get only the extension
  ext="${filename#*.}"
  if [[ "$ext" != "yaml" && "$ext" != "yml" ]]; then
    echo "Erro: o arquivo '$yaml_file' não é YAML"
    exit 1
  fi

  show_menu "$yaml_file"
  exit 0
fi

# Display available menus
# -----------------------------------------------------------------------
menu_files=($(list_menus))

if [[ ${#menu_files[@]} -eq 0 ]]; then
  echo "No menu files found in $MENUS_DIR"
  exit 1
fi

# Build menu options array
declare -A file_map
display_info=()

for file in "${menu_files[@]}"; do
  menu_name=$(get_menu_name "$file")
  display_info+=("$menu_name")
  file_map["$menu_name"]="$file"
done

# Create the fzf command with dynamic preview and bind cases
# -----------------------------------------------------------------------
header_text="JAM"
selection="$(
  printf "%s\n" "${display_info[@]}" |
    fzf \
      --header="$(figlet "$header_text")" \
      --border-label=" 🎸 $header_text " \
      --prompt="🎸 $header_text: "
)"

if [[ -n "$selection" ]]; then
  show_menu "${file_map[$selection]}"
fi
