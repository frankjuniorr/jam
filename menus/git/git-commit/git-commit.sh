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

# undo commit, and files back to the 'stage area'
undo() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  git reset --soft HEAD^
}

# Add the current modifications in git status to the last commit (HEAD), and force push.
amend() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  git add . && git commit --amend --no-edit && git push --force-with-lease
}

# Create a new commit interactively
new() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  # Verifica se há modificações no "git status".
  # - ! git diff --quiet : Verifica se há modificações "not staged"
  # - ! git diff --cached --quiet : Verifica se há modificações "staged"
  if ! git diff --quiet || ! git diff --cached --quiet; then
    local commit_title=$(gum input --cursor.foreground=2 --no-show-help --placeholder="Type the commit message")
    local commit_body=$(gum write --cursor.foreground=2 --no-show-help --placeholder="Type the commit description")
    local current_branch=$(git branch --show-current)

    test -z "$commit_title" && echo "The commit title cannot be empty" && return 1

    if [ -z "$commit_body" ]; then
      git commit -a -m "$commit_title"
    else
      git commit -a -m "$commit_title" -m "$commit_body"
    fi
    git push -u origin "$current_branch"
  else
    echo " ✅ Nothing to commit"
    exit 0
  fi
}

# Function to squash multiple commits into a single one.
# You pass the number as a parameter, like this:
# git_squash_commits 5: It will consider the last 5 commits to squash.
squash() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  local amount_commits=$(gum input --cursor.foreground=2 --no-show-help --placeholder="Type the number of amount of commit")
  if [[ ! "$amount_commits" =~ ^[0-9]+$ ]]; then
    echo "❌ Error: please enter a valid number"
    exit 1
  fi

  if [ -n "$amount_commits" ]; then
    current_branch=$(git branch | grep "^*" | awk '{print $2}')
    git rebase -i HEAD~$amount_commits
    git push origin +${current_branch}
  else
    echo "type the amount of commits"
    return 1
  fi
}

# Function to squash multiple commits into a single one.
# It uses the number of times the last commit message was repeated.
squash_equals() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This is not a Git repository ❌"
    exit 1
  fi

  local last_repeated_commit_count
  last_repeated_commit_count=$(git log --format=%s -n 20 | uniq -c | head -n 1 | awk '{print $1}')

  current_branch="$(git branch --show-current)"

  git rebase -i HEAD~"${last_repeated_commit_count}"
  git push origin +"${current_branch}"
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
