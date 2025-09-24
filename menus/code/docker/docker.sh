#!/usr/bin/env bash
##################################################################################
# Descrição:
# Menu that shows utility function Docker
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
dependencies=(docker gum lazydocker)
is_cmd_installed dependencies

# função que destrói todo o ambiente docker na máquina
# ----------------------------------------------------------------------
destroy() {
  yes | docker system prune -a
  yes | docker volume prune
}

# Docker PS formatted to print only my most used fields
# ----------------------------------------------------------------------
ps() {
  docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Size}}"
}

# Entra no shell de um container docker que esteja em execução, de maneira interativa com fzf
# ----------------------------------------------------------------------
shell() {
  local containers_list
  mapfile -t containers_list < <(docker ps --format "{{.Names}}")

  local container_selected=$(create_generic_fzf_menu containers_list "Containers")

  # Se nenhum container foi selecionado, sai
  if [ -z "$container_selected" ]; then
    echo "Nenhum container selecionado."
    exit 1
  fi

  # Executa o bash interativo no container selecionado
  docker exec -it "$container_selected" bash
}

ephemeral() {
  local docker_color="#0db7ed"
  local images=(
    "Ubuntu"
    "Arch Linux"
    "Rocky Linux"
    "Alpine"
  )

  local image
  local image=$(create_generic_fzf_menu images "Images" "false" "")

  if [ -z "$image" ]; then
    gum style --foreground="$docker_color" "Any docker image was selected"
    exit 1
  fi

  local registry="ghcr.io"
  local user="frankjuniorr"
  local repository="docker-images"

  case "$image" in
  "Ubuntu")
    init_cmd=(
      "clear"
      "figlet \"$image\""
      "exec bash"
    )
    image_url="${registry}/${user}/${repository}/ubuntu-vanilla:latest"
    ;;
  "Arch Linux")
    init_cmd=(
      "clear"
      "figlet \"$image\""
      "exec bash"
    )
    image_url="${registry}/${user}/${repository}/archlinux-vanilla:latest"
    ;;
  "Rocky Linux")
    init_cmd=(
      "clear"
      "figlet \"$image\""
      "exec bash"
    )
    image_url="${registry}/${user}/${repository}/rockylinux-vanilla:latest"
    ;;
  "Alpine")
    init_cmd=(
      "clear"
      "figlet \"$image\""
      "exec bash"
    )
    image_url="${registry}/${user}/${repository}/alpine-vanilla:latest"
    ;;
  esac

  gum style --foreground="$docker_color" "Docker Image: $image"
  gum style --foreground="$docker_color" "Commands:"

  cmd_str=$(printf '%s && ' "${init_cmd[@]}")
  cmd_str=${cmd_str% && }

  gum style --foreground="$docker_color" "$cmd_str"

  local container_name=$(basename "$image_url" | cut -d ":" -f1)

  docker pull "$image_url"
  docker run --rm -it \
    --name "$container_name" \
    "$image_url" \
    sh -c "$cmd_str"
}

# Exibe o log um container docker que esteja em execução, de maneira interativa com fzf
# ----------------------------------------------------------------------
logs() {
  local containers_list
  mapfile -t containers_list < <(docker ps --format "{{.Names}}")

  local container_selected=$(create_generic_fzf_menu containers_list "Containers")

  # Se nenhum container foi selecionado, sai
  if [ -z "$container_selected" ]; then
    echo "Nenhum container selecionado."
    exit 1
  fi

  # Executa o bash interativo no container selecionado
  docker logs "$container_selected"
}

tui() {
  lazydocker
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
