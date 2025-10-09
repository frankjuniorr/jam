#!/usr/bin/env bash
##################################################################################
# Descrição:
# Menu that create laboratory evironments
#
##################################################################################

# CONFIG
# -----------------------------------------------------------------------
set -e
set -u

# Import dependencies
#---------------------------------------------------------------
source "${SCRIPT_ROOT_DIR}/core/control.sh"

start_ephemeral_container() {
  dependencies=(docker gum)
  is_cmd_installed dependencies

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

  #TODO: Add this information about registry on the config file later
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

start_k8s_cluster() {
  dependencies=(k3d)
  is_cmd_installed dependencies

  #TODO: Move this variables to config file later
  local server_count=1
  local worker_count=3
  local cluster_name="lab-cluster"

  # Verifica se o cluster já existe
  if k3d cluster list | grep -q "^${cluster_name}\b"; then
    echo "✅ The cluster '${cluster_name}' already exists!"
  else
    echo "🚀 Creating the cluster '${cluster_name}'..."
    k3d cluster create "$cluster_name" \
      --servers "$server_count" \
      --agents "$worker_count" \
      --port 80:80@loadbalancer \
      --port 443:443@loadbalancer \
      --api-port 6550 \
      --wait
    echo "✅ Cluster '${cluster_name}' created with success!"
  fi
}

start_vm() {
  dependencies=(virt-install qemu-img gum fd)
  is_cmd_installed dependencies

  local old_pwd=$(pwd)
  local images_dir="/var/lib/libvirt/images"

  cd "$images_dir"
  local iso_files=($(fd --strip-cwd-prefix=always --extension iso .))
  local iso_file=$(create_generic_fzf_menu iso_files "Find ISO files" "false" "")

  test -z "$iso_file" && echo "You need select a iso file" && exit 0

  local vm_name=$(echo "$iso_file" | cut -d "-" -f1)
  vm_name="${vm_name,,}-lab" # transform to lower case
  local virtual_disk_file="${images_dir}/${vm_name}.qcow2"

  if [ -f "$virtual_disk_file" ]; then
    echo "The disk file $virtual_disk_file already exists"
    exit 1
  fi

  echo "Checking if VM $vm_name already exist"
  if sudo virsh list --all | grep -q " $vm_name "; then
    echo "$vm_name already exists"
    exit 1
  fi

  local vm_ram=$(gum choose --cursor.foreground=2 --header="Choose a RAM memory in bytes" --no-show-help "2048" "4096" "6144" "8192")
  local vm_cpu=$(gum choose --cursor.foreground=2 --header="Choose a CPU" --no-show-help "1" "2" "4" "6")
  local disk_size=$(gum choose --cursor.foreground=2 --header="Choose a Disk Size" --no-show-help "10G" "20G" "40G" "50G" "80G" "100G")

  local variant_query=$(echo "$vm_name" | cut -d "-" -f1)
  osinfo-query os --fields short-id | tail -n +3 | fzf --gap=0 --gap-line "" --query="$variant_query"

  # Cria uma imagem de disco de 10GB em formato qcow2
  qemu-img create -f qcow2 \
    "${images_dir}/${vm_name}.qcow2" "$disk_size"

  # Cria a VM em si
  sudo virt-install \
    --name "$vm_name" \
    --ram "$vm_ram" \
    --vcpus "$vm_cpu" \
    --disk path="$virtual_disk_file,bus=virtio,format=qcow2" \
    --os-variant ubuntu24.04 \
    --network network=default,model=virtio \
    --graphics vnc \
    --cdrom "$iso_file" \
    --boot cdrom,hd,menu=on

  sleep 2
  virt-viewer --connect qemu:///system "$vm_name"

  cd "$old_pwd"
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
