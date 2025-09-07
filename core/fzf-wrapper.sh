#!/usr/bin/env bash
#########################################################################
# Description:
#   Configuration file and auxiliary functions related to the formation of the menu with 'fzf'
#########################################################################

# CONFIG
# -----------------------------------------------------------------------
set -e

# Arquivo de help do 'fzf'
HELP_FILE="${CORE_DIR}/fzf_help.md"

# Colors logic to 'fzf'
# -----------------------------------------------------------------------
case "$color_theme" in
"dark")
  FZF_COLORS="--color=pointer:1 --color=fg+:7,bg+:-1"
  ;;
"light")
  FZF_COLORS="--color=pointer:3 --color=fg+:0,bg+:7"
  ;;
*)
  FZF_COLORS=""
  ;;
esac

# Default values from fzf parameters
# -----------------------------------------------------------------------
export FZF_DEFAULT_OPTS="
  --border rounded
  --border-label-pos center
  --layout reverse
  --info right
  --prompt ' : '
  --pointer ''
  --marker '✓'
  --gap
  --gap-line \"───\"
  --preview-window=right:50%:wrap
  --height=30%
  --ansi
  --bind \"ctrl-d:toggle-preview\"
  --bind 'ctrl-h:preview(
        script -qfc \"glow $HELP_FILE\" /dev/null
  )'
  --tmux 90%
  $FZF_COLORS
"
# Functions
# -----------------------------------------------------------------------

# Create description markdown files
create_md_file_description() {
  local menu_item="$1"
  local filename="$2"
  local filename_relative="${filename#$SCRIPT_ROOT_DIR/menus/}"
  filename_relative="$(dirname $filename_relative)"

  local menu_name=$(basename "$(dirname "$filename")")
  local parent_folder="${SCRIPT_ROOT_DIR}/menus/${filename_relative}"
  local script_name="$(basename "$filename" ".sh")"

  # remove the fisrt caractere, in this case is the emoji
  formatted_name="${menu_item:2}"

  # converte all upper-case to lower-case, and replace all spaces to `_`
  formatted_name=$(echo "$formatted_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | sed 's/^_//')

  local description_file="${parent_folder}/docs/${menu_name}-${script_name}-${formatted_name}.md"

  # cria a pasta de docs, caso não exista
  local docs_folder=$(dirname "$description_file")
  test ! -d "$docs_folder" && mkdir -p "$docs_folder"

  # cria o arquivo de docs, caso não exista
  if [[ ! -f "$description_file" ]]; then
    echo -e "# $menu_item" >"$description_file"
  fi

  echo "$description_file"
}

# The main menu 'fzf' function.
# show the Menu based on '.yaml' file of menus
# and handle the action
create_fzf_menu() {
  # Reference to menu items array
  local -n items="$1"

  # filename, only the name, without extension and `_` instead of `-`
  #   local filename=$(basename "$2" ".sh" | sed 's/[_-]/ /g')

  # Header text for the menu
  #   local header_text=$(__format_title "$2")
  # local header_text="$2"

  # Dynamically build display_options and description files
  local display_options=()
  local preview_cases=""
  local bind_cases=""

  for item in "${items[@]}"; do
    # Split by | delimiter
    IFS='|' read -r icon label title script_path action <<<"$item"
    local menu_item="$icon $label"

    local header_text="$title"
    local actions+=("$action")

    display_options+=("$menu_item")

    # Generate description file and export its path
    export "${action}_desc_file"=$(create_md_file_description "$menu_item" "$script_path")

    # Build preview cases dynamically
    preview_cases+="\"$menu_item\") script -qfc \"glow \$${action}_desc_file\" /dev/null ;;"

    # Build bind cases dynamically
    bind_cases+="\"$menu_item\") \${EDITOR:-vim} \"\$${action}_desc_file\" ;;"
  done

  # Create the fzf command with dynamic preview and bind cases
  local selection=$(
    printf "%s\n" "${display_options[@]}" |
      fzf \
        --header="$(figlet "$header_text")" \
        --border-label=" ⚡ $header_text " \
        --prompt="⚡ $header_text: " \
        --preview "
        case {} in
          $preview_cases
        esac" \
        --bind "ctrl-e:execute(
        case {} in
          $bind_cases
      esac
      )"
  )

  if [[ -n "$selection" ]]; then
    # Find the matching action
    for i in "${!display_options[@]}"; do
      if [[ "${display_options[$i]}" == "$selection" ]]; then
        # Execute the action
        bash "$script_path" "${actions[$i]}"
        break
      fi
    done
  else
    return 0
  fi

}

# Auxiliar function to create 'fzf' menu in generic way
# based on a generic array passed by parameter
# and return the selected item, to function that called this function handle the action.
create_generic_fzf_menu() {
  # Reference to menu items array
  local -n items="$1"
  local header_text="$2"
  local multi_selection="${3:-false}"
  local preview_cmd="$4"

  local display_options=()

  for item in "${items[@]}"; do
    # Split by | delimiter
    IFS='|' read -r icon label <<<"$item"

    # esse 'xargs' aqui funciona como ".trim()". Ele remove os "trailing spaces"
    menu_item=$(echo "$icon $label" | xargs)

    display_options+=("$menu_item")
  done

  # 'fzf' parameters array
  local fzf_args=(
    --border-label=" ⚡ $header_text "
    --prompt="⚡ $header_text: "
  )

  # only add `--header` if `$header_text` is not null
  if [[ -n "$header_text" ]]; then
    fzf_args+=(--header="$(figlet "$header_text")")
  fi

  # If '$multi_selection' is true, the menu accepts multi-selection
  if [[ "$multi_selection" == "true" ]]; then
    fzf_args+=("--multi")
  fi

  # If '$preview_cmd' is not null, set the preview command
  if [ -n "$preview_cmd" ]; then
    fzf_args+=("--preview" "${preview_cmd[@]}")
  fi

  # Create the fzf command with dynamic preview and bind cases
  local selection=$(printf "%s\n" "${display_options[@]}" | fzf "${fzf_args[@]}")

  echo "$selection"
}

# Create the main help file
create_help_file() {
  if [ ! -f "$HELP_FILE" ]; then
    cat <<'EOF' >"$HELP_FILE"
# Legenda de comandos

- **ctrl-d** : alterna preview
- **ctrl-e** : edita descrição
- **ctrl-h** : mostra esta legenda
EOF
  fi
}

# -----------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------
create_help_file
