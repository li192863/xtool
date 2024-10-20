#!/bin/bash

# Script Name: xscript.sh
# Description: A combined tool of xscp and xssh to run a local script on a remote machine.
# Author: Chestnut

xscript_usage() {
  # Help message
  echo "usage: xscript [-u <user>] [-p <passwd>] [-d <dest>] <ip-string> <local-srcipt-path> [args]"
  echo "   "
  echo "  -u | --user              : Login user"
  echo "  -p | --password          : Login password"
  echo "  -d | --destination       : Destination where the script will be transfered to"
  echo "  -h | --help              : Show this message"
}

xscript() {
  # Parse args
  # set defaults
  local user=$(get_config '.execute.xscript.user')
  local pass=$(get_config '.execute.xscript.password')
  local dest=$(get_config '.execute.xscript.destination')
  # positional args
  local args=()
  # named args
  while [ "$1" != "" ]; do
    case "$1" in
    -u | --user)
      user="$2"
      shift
      ;;
    -p | --password)
      pass="$2"
      shift
      ;;
    -d | --destination)
      dest="$2"
      shift
      ;;
    -h | --help)
      xscript_usage
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
  local script=$(get_path "$2")
  [ -n "$3" ] && args="${@:3}"
  # validate required args
  if [ -z "${ip}" ]; then
    echo "Missing required argument '<ip-string>'." 
    xscript_usage
    return 1
  fi
  if [ -z "${script}" ]; then
    echo "Missing required argument '<local-srcipt-path>'." 
    xscript_usage
    return 1
  fi

  # Execute
  xscpu -u "$user" -p "$pass" "$ip" "$script" "$dest"
  if xssh -u "$user" -p "$pass" "$ip" "test -d \"$dest\"" &>/dev/null; then
    # if it is a dir, get the path
    local script_name=$(basename "$script")
    xssh -u "$user" -p "$pass" "$ip" "/bin/sh $dest/$script_name $args"
  else
    xssh -u "$user" -p "$pass" "$ip" "/bin/sh $dest $args"
  fi
}