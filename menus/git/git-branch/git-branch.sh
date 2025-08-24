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

# Faz o `git fetch` com o spinner do `gum`
__fetch() {
  gum spin \
    --spinner.foreground=3 \
    --spinner dot \
    --show-output \
    --title "🔄 Fetching repository..." \
    -- git fetch --prune
}

# check dependencies
dependencies=(gum git lazygit)
is_cmd_installed dependencies

switch() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  # Atualiza a referências do repositório
  __fetch

  # Get local branches and format with green color
  local local_branches=$(git branch --format='%(refname:short) %(committerdate:relative)' | grep -v HEAD)

  # Get remote branches and format with red color for names and blue for dates
  local remote_branches=$(git branch -r --format='%(refname:short) %(committerdate:relative)' | grep -v HEAD | grep "^origin/")

  # Combine the lists
  mapfile -t all_branches < <(
    echo -e "${local_branches}\n${remote_branches}" | grep -v "^$"
  )

  local branch_selected=$(create_generic_fzf_menu all_branches "Branches")
  branch_selected=$(echo "$branch_selected" | sed -E "s/^([^ ]+)(.*)/\1/")

  # Exit if no branch was selected
  if [ -z "$branch_selected" ]; then
    echo " ❌ No branch selected."
    exit 1
  fi

  git checkout "$branch_selected"
}

# Deleta todas as branches locais, deixando só a current branch
clean() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  local branches=$(git branch | grep -v '^\*' | awk '{print $1}')

  if [ -n "$branches" ]; then
    echo "🧹 Apagando branches locais:"
    echo "$branches" | xargs -n1 git branch -D
  fi

  __fetch
}

default() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  local default_branch=$(git rev-parse --abbrev-ref origin/HEAD | cut -d '/' -f2)
  local current_branch=$(git branch --show-current)

  if [ "$default_branch" != "$current_branch" ]; then
    git checkout "$default_branch"
  fi

  git pull
}

# Usado para checkar se a minha branch corrente, existe no repositório ou não
check() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  local current_branch=$(git branch --show-current)

  __fetch

  if git branch -r | grep -q "origin/${current_branch}"; then
    echo "This branch $current_branch exists in the repository"
  else
    echo "This branch $current_branch doens't exists in the repository"
    if gum confirm \
      --prompt.foreground=2 \
      --selected.background=2 \
      --no-show-help \
      "Clean up local branches?"; then
      default && clean
    fi
  fi
}

# Cria uma nova branch de maneira interativa
new() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  # faz o fetch pra atualizar as referências do repositório
  __fetch

  local branch_src
  local branch_new
  local commit_title
  local commit_body
  local remote_branches

  local default_branch=$(git rev-parse --abbrev-ref origin/HEAD | cut -d '/' -f2)

  # Menu: branch de origem
  local options=("Default (${default_branch})" "other")
  local branch_selected=$(create_generic_fzf_menu options "Source Branche")

  if [ "$branch_selected" != "other" ]; then
    branch_src="$default_branch"

  else
    mapfile -t remote_branches < <(
      git branch -r | grep -v "origin/HEAD" | sed "s/^ *//g" | sed "s|origin/||g"
    )

    local remote_branch_selected=$(create_generic_fzf_menu remote_branches "Remote Branche")
    branch_src="$remote_branch_selected"
  fi

  branch_new=$(gum input --cursor.foreground=2 --no-show-help --placeholder="Type the new branch name")

  git checkout "$branch_src"
  git pull
  git checkout -b "$branch_new"

  # Verifica se há modificações no "git status".
  # - ! git diff --quiet : Verifica se há modificações "not staged"
  # - ! git diff --cached --quiet : Verifica se há modificações "staged"
  if ! git diff --quiet || ! git diff --cached --quiet; then
    commit_title=$(gum input --cursor.foreground=2 --no-show-help --placeholder="Type commit message")
    commit_body=$(gum write --cursor.foreground=2 --no-show-help --placeholder="Type commit description")

    test -z "$commit_title" && echo "❌ The commit cannot be empty" && exit 1

    if [ -z "$commit_body" ]; then
      git commit -a -m "$commit_title"
    else
      git commit -a -m "$commit_title" -m "$commit_body"
    fi

    # TODO: usar o 'gum confirm' para perguntar, se quer abrir um MR ou não.
    # caso sim:
    #   - criar um menu fixo no fzf, com os username dos "assign" do MR.
    #   - usar o `glab` para criar o MR
    # caso não:
    # encerra o comando
  fi

  git push origin -u "$branch_new"
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
