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

is_mounted() {
  # Check if the dir is mounted.
  # "$remote_host:$remote_dir on $local_mount_point ..."
  if mount | grep -q " on $1 "; then
    return 0
  fi
  return 1
}