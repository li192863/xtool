#!/bin/bash

# Script Name: xfs.sh
# Description: A combined tool of xsshfs and xumount to mount and unmount a remote file system locally.
# Author: Chestnut

xfs_usage() {
  # Help message
  echo "usage: xfs [-u <user>] <ip-string> [src-dir] [dest-dir]"
  echo "   "
  echo "  -u | --user              : Login user"
  echo "  -h | --help              : Show this message"
}

xfs() {
  # Parse args
  # set defaults
  local user=$(get_config '.file_system.xfs.user')
  local src_dir=$(get_config '.file_system.xfs.src_dir')
  local dest_dir=$(get_config '.file_system.xfs.dest_dir')
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
      xfs_usage
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
    xfs_usage
    return 1
  fi

  # Execute
  # mount if not mount
  local mount_point="$dest_dir/$(echo "$ip" | sed -e 's/\./-/g')"
  if ! is_mounted "$mount_point"; then
    xsshfs -u "$user" "$ip" "$src_dir" "$dest_dir"
    # cd to mount point
    local return_status="$?"
    if [ "$return_status" = 0 ]; then
      cd "$mount_point"
    fi
    return "$return_status"
  fi
  # ask user to umounted or not if mounted
  local msg=$(mount | grep "$mount_point" | awk '{print $1 " -> " $3}')
  echo -n "Already mounted: $msg, do you wish to unmount? [Y/n]: "
  read input
  input=$(echo "$input" | tr '[:upper:]' '[:lower:]')
  case "$input" in
  y | yes | "")
    # prevent unmount fail
    if [[ "$(pwd)" == "$mount_point"* ]] || [[ "$(pwd)" == "$mount_point/"* ]]; then
      cd "$dest_dir"
    fi
    xumount "$ip" "$dest_dir"
    ;;
  *)
    echo "Abort."
    ;;
  esac
}