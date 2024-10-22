#!/bin/bash

# Script Name: xssh-copy-id.sh
# Description: A modified tool of ssh-copy-id.
# Author: Chestnut

xssh_copy_id_usage() {
  # Help message
  echo "usage: xssh-copy-id [-u <user>] [-p <passwd>] <ip-string> [identity file]"
  echo "   "
  echo "  -u | --user              : Login user"
  echo "  -p | --password          : Login password"
  echo "  -h | --help              : Show this message"
}

xssh-copy-id() {
  # Parse args
  # set defaults
  local user=$(get_config '.connect.xssh-copy-id.user')
  local pass=$(get_config '.connect.xssh-copy-id.password')
  local identity_file=$(get_config '.connect.xssh-copy-id.identity_file')
  local options=($(get_config '.connect.xssh-copy-id.options | join(" ")'))
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
    -h | --help)
      xssh_copy_id_usage
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
  [ -n "$2" ] && identity_file=$(get_path "$2")
  # validate required args
  if [ -z "${ip}" ]; then
    echo "Missing required argument '<ip-string>'." 
    xssh_copy_id_usage
    return 1
  fi

  # Execute
  if [ -z "$identity_file" ]; then
    echo "ssh-copy-id "${options[@]}" $user@$ip"
    sshpass -p "$pass" ssh-copy-id "${options[@]}" "$user"@"$ip" &>/dev/null
  else
    echo "ssh-copy-id -i $identity_file "${options[@]}" $user@$ip"
    sshpass -p "$pass" ssh-copy-id -i "$identity_file" "${options[@]}" "$user"@"$ip" &>/dev/null
  fi
}
