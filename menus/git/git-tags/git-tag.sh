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

# Função que cria uma nova branch local, a partir deu uma tag no git
new_branch_from_tag() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  local git_tags
  mapfile -t git_tags < <(git tag --sort=-v:refname)
  local tag_selected=$(create_generic_fzf_menu git_tags "Tags" "false" "")

  test -z "$tag_selected" && echo "❌ The tag cannot be empty" && exit 1

  git checkout -b "$tag" "$tag"
}

# Função para renomear uma tag no git
rename() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  local git_tags
  mapfile -t git_tags < <(git tag --sort=-v:refname)
  local old_tag=$(create_generic_fzf_menu git_tags "Tags" "false" "")
  test -z "$old_tag" && echo "❌ The tag cannot be empty" && exit 1

  new_tag=$(gum input --cursor.foreground=2 --no-show-help --placeholder="Type the new tag name")
  test -z "$new_tag" && echo "❌ The tag name cannot be empty" && exit 1

  git tag "$new_tag" "$old_tag"
  git tag -d "$old_tag"
  git push origin ":refs/tags/${old_tag}"
  git push --tags
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
