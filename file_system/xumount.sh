#!/bin/bash

# Script Name: xumount.sh
# Description: A modified tool of umount.
# Author: Chestnut

xumount_usage() {
  # Help message
  echo "usage: xumount <ip-string> [dest_dir]"
  echo "   "
  echo "  -h | --help              : Show this message"
}

xumount() {
  # Parse args
  # set defaults
  local dest_dir=$(get_config '.file_system.xumount.dest_dir')
  local options=($(get_config '.file_system.xumount.options | join(" ")'))
  # positional args
  local args=()
  # named args
  while [ "$1" != "" ]; do
    case "$1" in
    -h | --help)
      xumount_usage
      return 0
      ;;
    *)
      args+=("$1") # if no match, add it to the positional args
      ;;
    esac
    shift # move to next kv pair
  done
  # restore positional args
  set -- "${args[@]}"
  # set positionals to vars
  local ip=$(get_ip "$1")
  [ -n "$2" ] && dest_dir=$(realpath "$2")
  # validate required args
  if [ -z "${ip}" ]; then
    echo "Missing required argument '<ip-string>'." 
    xumount_usage
    return 1
  fi

  # Execute
  # check if unmounted
  local mount_point="$dest_dir/$(echo "$ip" | sed -e 's/\./-/g')"
  if ! is_mounted "$mount_point"; then
    echo "Not mounted yet: $mount_point"
    return 1
  fi
  # unmount target
  local cmd="sudo umount ${options[@]} \"${mount_point}\""
  echo "${cmd}"
  eval "${cmd}"
  # clean if succeed
  local return_status="$?"
  if [ "$return_status" = 0 ]; then
    sudo rm -rf "$mount_point"
  fi
  return "$return_status"
}
