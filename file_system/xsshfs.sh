#!/bin/bash

# Script Name: xsshfs.sh
# Description: A modified tool of sshfs.
# Author: Chestnut

xsshfs_usage() {
  # Help message
  echo "usage: xsshfs [-u <user>] <ip-string> [src-dir] [dest-dir]"
  echo "   "
  echo "  -u | --user              : Login user"
  echo "  -h | --help              : Show this message"
}

xsshfs() {
  # Parse args
  # set defaults
  local user=$(get_config '.file_system.xsshfs.user')
  local src_dir=$(get_config '.file_system.xsshfs.src_dir')
  local dest_dir=$(get_config '.file_system.xsshfs.dest_dir')
  local options=($(get_config '.file_system.xsshfs.options | join(" ")'))
  # positional args
  local args=()
  # named args
  while [ "$1" != "" ]; do
    case "$1" in
    -u | --user)
      user="$2"
      shift
      ;;
    -h | --help)
      xsshfs_usage
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
  [ -n "$2" ] && src_dir="$2"
  [ -n "$3" ] && dest_dir=$(realpath "$3")
  # validate required args
  if [ -z "${ip}" ]; then
    echo "Missing required argument '<ip-string>'." 
    xsshfs_usage
    return 1
  fi

  # Execute
  # check if mounted
  local mount_point="$dest_dir/$(echo "$ip" | sed -e 's/\./-/g')"
  if is_mounted "$mount_point"; then
    local msg=$(mount | grep "$mount_point" | awk '{print $1 " -> " $3}')
    echo "Already mounted: $msg"
    return 1
  fi
  # mount target
  sudo mkdir -p "$mount_point"
  local cmd="sudo sshfs ${options[@]} \"${user}\"@\"${ip}\":\"${src_dir}\" \"${mount_point}\""
  echo "${cmd}"
  eval "${cmd}"
  
  # clean if failed
  local return_status="$?"
  if [ "$return_status" != 0 ]; then
    sudo rm -rf "$mount_point"
  fi
  return "$return_status"
}
