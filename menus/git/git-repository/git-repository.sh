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

github_create() {
  bash "${SCRIPT_ROOT_DIR}/menus/git/git-repository/gh-create.sh"
}

# Faz o `git fetch` com o spinner do `gum`
fetch() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  gum spin \
    --spinner.foreground=3 \
    --spinner dot \
    --show-output \
    --title "🔄 Fetching repository..." \
    -- git fetch --prune
}

# Alias para quando eu quero dar um 'git pull', levando em conta
# APENAS o que tem no repositório.
# útil, pra quando eu faço um Amend em um commit, e quero dar um 'git pull' depois
force_pull() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  current_branch=$(git branch | grep "^*" | awk '{print $2}')
  git fetch origin
  git reset --hard origin/${current_branch}
}

# Faz clone de um repositório git a partir da URL, e entra na pasta
clone() {

  local repository_name=$(gum input --no-show-help --placeholder="Digite a URL do repositório")

  local repository_folder=$(basename "$repository_name" ".git")
  git clone "$repository_name"
  cd "$repository_folder"
  ls
}

# pega o nome do repositório do git
repository_name() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  git config --get --local remote.origin.url
}

# abre o repositório no browser
repository_web() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  local repository_url=$(repository_name)
  repository_url=$(echo "$repository_url" | sed 's/gitlab@//g' | sed 's/git@//g' | sed 's/.git//g' | sed 's|:|/|g')
  google-chrome-stable "$repository_url"
}

#TODO: Criar uma função nova aqui que cria um repositório temporário private de laboratório no Github
# O intuito aqui é fazer testes no git, e aí eu crio um repo para estudos.
# Depois eu deleto. Se eu conseguir deletar por aqui, melhor ainda.

################################################################
# MAIN
################################################################

# Execute a function if passed as argument
function_name="$1"

if [[ -n "$function_name" ]]; then
  "$function_name"
  exit "$?"
fi
