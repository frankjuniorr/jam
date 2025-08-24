#!/usr/bin/env bash
#########################################################################
# Description:
#   File with various auxiliary functions for control, validations, and similar tasks.
#########################################################################

# CONFIG
# -----------------------------------------------------------------------
set -e

# Functions
# -----------------------------------------------------------------------

# Parse YAML using yq
# parameter:
# - yaml file
# - 'yq' query
parse_yaml() {
  local file="$1"
  local query="$2"

  if command -v yq &>/dev/null; then

    local os=$(grep "^NAME=" /etc/os-release | cut -d "=" -f2 | sed 's/"//g')
    yq -r "$query" "$file"
  else
    echo "Error: yq is required to parse YAML" >&2
    echo "Install it first" >&2
    exit 1
  fi
}

# Check if necessary dependencies are installed
# parameter:
# - array with all needed dependencies
is_cmd_installed() {
  local -n cmd_list="$1"
  local cmd_missing=()

  for missing in "${cmd_list[@]}"; do
    if ! command -v "$missing" >/dev/null 2>&1; then
      cmd_missing+=("$missing")
    fi
  done

  if [ ${#cmd_missing[@]} -gt 0 ]; then
    echo "This dependencies are needed, to use this option:"
    echo "----------------------------------------------------"
    for missing in "${cmd_missing[@]}"; do
      echo "- ⚠️  $missing"
    done
    echo "----------------------------------------------------"
    echo "Please, install it first"
    return 1
  fi
}

# Function to show a menu from a YAML file
show_menu() {
  local menu_file="$1"

  local title script
  display_info=()

  # Parse the menu YAML
  title=$(parse_yaml "$menu_file" ".title")
  script=$(parse_yaml "$menu_file" ".script")
  script_path="${MENUS_DIR}/${script}"

  # Check if script exists
  if [[ ! -f "$script_path" ]]; then
    echo "Script not found: $script_path"
    return 1
  fi

  # Get all items from YAML
  local item_count=$(parse_yaml "$menu_file" ".items | length")
  local display_options=()
  local actions=()

  # Build arrays directly from YAML without temp file
  for ((i = 0; i < item_count; i++)); do
    local icon=$(parse_yaml "$menu_file" ".items[$i].icon")
    local label=$(parse_yaml "$menu_file" ".items[$i].label")
    local action=$(parse_yaml "$menu_file" ".items[$i].action")

    display_info+=("$icon|$label|$title|$script_path|$action")
  done

  create_fzf_menu display_info

}

# Function to discover and list available menus
list_menus() {
  fd --type file --max-depth 2 --extension yaml --extension yml . "$MENUS_DIR" | sort
}

# Function to get menu display name from yaml file
get_menu_name() {
  local menu_file="$1"
  local title

  icon=$(parse_yaml "$menu_file" ".icon")
  title=$(parse_yaml "$menu_file" ".title")
  title="$icon $title"

  echo "$title"
}

# -----------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------

# Set configuration
export MENUS_CONFIG_FILE="$SCRIPT_ROOT_DIR/config.yaml"
if [ ! -f "$MENUS_CONFIG_FILE" ]; then
  export MENUS_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/${APP_NAME}/config.yaml"
  test ! -f "$MENUS_CONFIG_FILE" && echo "Config file not found: $MENUS_CONFIG_FILE" && return 1
fi

color_theme=$(parse_yaml "$MENUS_CONFIG_FILE" ".color_theme")
tematic_color=$(parse_yaml "$MENUS_CONFIG_FILE" ".tematic_color")

# Import the core functionality
# -----------------------------------------------------------------------
source "${SCRIPT_ROOT_DIR}/core/fzf-wrapper.sh"
