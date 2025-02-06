#!/bin/bash

# Script Name: util.sh
# Description: Common utils.
# Author: Chestnut

get_config() {
  # Get config from config.yml
  yq eval "$1" "${XTOOL_ROOT}/config.yml"
}

get_ip() {
  # Get ip from a string.
  echo "$1" | grep -oE '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | head -n 1
}

get_path() {
  # Get absolute path. If it is a windows path, transfer it to wsl path.
  wslpath -a "$1" 2>/dev/null && echo -n "$CMD_OUTPUT" || echo "$1"
}

get_params_slice() {
  # Get python slice of params and execute command on each element
  # Note: Elements to be passed will add '"' on each side automatically.
  local start="$1"
  local end="$2"
  local cmd_prefix="$3"
  local cmd_suffix="$4"
  shift 4

  local total=$#
  # Handle neg
  [ $end -lt 0 ] && end=$((total + end))
  [ $start -lt 0 ] && start=$((total + start))
  # Handle bound
  [ $start -lt 0 ] && start=0
  [ $end -gt $total ] && end=${total}

  # Loop through the sliced parameters
  for ((i = start; i < end; i++)); do
    element="${@:$((i + 1)):1}"
    eval_value="${cmd_prefix}""\"${element}\"""${cmd_suffix}"
    # Uncomment this line to show what has be evaled
    # echo "$eval_value"
    output=$(eval "${eval_value}")
    echo -n "\"${output}\" "
  done
  echo
}

is_mounted() {
  # Check if the dir is mounted.
  # "$remote_host:$remote_dir on $local_mount_point ..."
  if mount | grep -q " on $1 "; then
    return 0
  fi
  return 1
}
