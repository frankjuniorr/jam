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
    "ubuntu:24.04"
    "archlinux:latest"
    "rockylinux:9.3"
    "alpine:latest"
  )

  local image
  local image=$(create_generic_fzf_menu images "Images" "false" "")

  if [ -z "$image" ]; then
    gum style --foreground="$docker_color" "Any docker image was selected"
    exit 1
  fi

  local update_cmd
  local env_vars
  case "$image" in
  ubuntu:* | debian:*)
    init_cmd=(
      "apt-get update"
      "apt-get install -y tzdata vim bash curl wget figlet"
      "clear"
      "figlet \"$image\""
      "exec bash"
    )
    env_vars=(
      "-e" "DEBIAN_FRONTEND=noninteractive"
      "-e" "TZ=America/Recife"
    )
    ;;
  archlinux:*)
    init_cmd=(
      "pacman -Syu --noconfirm"
      "pacman -Sy --noconfirm vim bash curl wget figlet"
      "clear"
      "figlet \"$image\""
      "exec bash"
    )
    env_vars=()
    ;;
  rockylinux:* | centos:* | fedora:*)
    init_cmd=(
      "dnf update -y"
      "dnf install -y vim bash ncurses epel-release"
      "dnf install -y figlet"
      "clear"
      "figlet \"$image\""
      "exec bash"
    )
    env_vars=()
    ;;
  alpine:*)
    init_cmd=(
      "apk update"
      "apk add vim bash curl wget figlet"
      "clear"
      "figlet \"$image\""
      "exec bash"
    )
    env_vars=()
    ;;
  *)
    init_cmd=("sh" "-c" "echo 'Nenhum gerenciador de pacotes detectado' && exec sh")
    ;;
  esac

  gum style --foreground="$docker_color" "Docker Image: $image"
  gum style --foreground="$docker_color" "Commands:"

  cmd_str=$(printf '%s && ' "${init_cmd[@]}")
  cmd_str=${cmd_str% && }

  gum style --foreground="$docker_color" "$cmd_str"

  local container_name=$(echo "$image" | cut -d ":" -f1)
  docker run --rm -it \
    -e TERM=xterm-256color \
    --name "$container_name" \
    "${env_vars[@]}" \
    "$image" \
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
