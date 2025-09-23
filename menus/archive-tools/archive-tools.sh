#!/usr/bin/env bash
##################################################################################
# Descrição:
# Menu that shows utility functions to archive files
#
# Dependências:
# - jq
##################################################################################

# CONFIG
# -----------------------------------------------------------------------
set -e
set -u

# Import dependencies
#---------------------------------------------------------------
source "${SCRIPT_ROOT_DIR}/core/control.sh"

# check dependencies
dependencies=(unzip unrar 7z fd)
is_cmd_installed dependencies

__list_files() {
  # Criando o array de arquivos suportados com fd
  local files=("$(fd --type f \
    --extension zip \
    --extension tar \
    --extension tgz \
    --extension "tar.gz" \
    --extension "tar.xz" \
    --extension "tar.bz2" \
    --extension tbz2 \
    --extension gz \
    --extension bz2 \
    --extension rar \
    --extension 7z \
    --max-depth 1)"
  )

  if [[ -z "$files" ]]; then
    echo "⚠️  Any archive files founded"
    return 1
  fi

  local file_selected=$(create_generic_fzf_menu files "Files" "false" "")

  if [[ -z "$file_selected" ]]; then
    echo "⚠️  Any file selected"
    return 1
  fi

  echo "$file_selected"

}

# Functions
# -----------------------------------------------------------------------
# Função para extrair arquivos
extract() {
  local file_selected
  if ! file_selected="$(__list_files)"; then
    echo "$file_selected"
    exit 1
  fi

  local filename=$(basename "$file_selected")
  case "$filename" in
  *.zip) unzip "$file_selected" ;;
  *.tar) tar --extract --verbose --file="$file_selected" ;;
  *.tar.gz | *.tgz) tar --extract --gzip --verbose --file="$file_selected" ;;
  *.tar.xz) tar --extract --xz --verbose --file="$file_selected" ;;
  *.tar.bz2 | *.tbz2) tar --extract --bzip2 --verbose --file="$file_selected" ;;
  *.gz) gunzip --verbose "$file_selected" ;;
  *.bz2) bunzip2 --verbose "$file_selected" ;;
  *.rar) unrar x --verbose -o+ "$file_selected" ;;
  *.7z) 7z x -bb3 "$file_selected" ;;
  *)
    echo "❌ Formato de arquivo não suportado: $file_selected"
    exit 1
    ;;
  esac
}

# Função para listar o conteúdo de arquivos
list_contents() {
  local file_selected
  if ! file_selected="$(__list_files)"; then
    echo "$file_selected"
    exit 1
  fi

  local filename="$(basename "$file_selected")"

  case "$filename" in
  *.zip) unzip -l "$file_selected" ;;
  *.tar) tar --list --file="$file_selected" ;;
  *.tar.gz | *.tgz) tar --list --gzip --file="$file_selected" ;;
  *.tar.xz) tar --list --xz --file="$file_selected" ;;
  *.tar.bz2 | *.tbz2) tar --list --bzip2 --file="$file_selected" ;;
  *.gz) echo "Arquivo gzip simples: $(basename "$file_selected" .gz)" ;;
  *.bz2) echo "Arquivo bzip2 simples: $(basename "$file_selected" .bz2)" ;;
  *.rar) unrar l "$file_selected" ;;
  *.7z) 7z l "$file_selected" ;;
  *)
    echo "❌ Formato de arquivo não suportado: $file_selected"
    exit 1
    ;;
  esac
}

compress() {
  local current_files=($(fd --type f --max-depth 1))
  local selected_files=$(create_generic_fzf_menu current_files "Compress" "true" "")

  # Transformando em array
  mapfile -t selected_files <<<"$selected_files"

  if [ ${#selected_files[@]} -eq 0 ]; then
    echo "❌ Any files selected"
    exit 1
  fi

  local compression_formats=("zip" "rar" "tar.gz" "7z")
  local format_selected=$(create_generic_fzf_menu compression_formats "Format" "false" "")

  if [[ -z "$format_selected" ]]; then
    echo "❌ Any format selected"
    exit 1
  fi

  local output_filename=$(gum input \
    --cursor.foreground="$tematic_color" \
    --no-show-help \
    --placeholder="Type the name of file")

  if [[ -z "$output_filename" ]]; then
    echo "❌ Any name are provided"
    exit 1
  fi

  case "$format_selected" in
  zip)
    zip -r "${output_filename}.zip" "${selected_files[@]}"
    ;;
  rar)
    rar a "${output_filename}.rar" "${selected_files[@]}"
    ;;
  "tar.gz")
    tar -czvf "${output_filename}.tar.gz" "${selected_files[@]}"
    ;;
  7z)
    7z a "${output_filename}.7z" "${selected_files[@]}"
    ;;
  *)
    echo "❌ Format unsupported: $format"
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
