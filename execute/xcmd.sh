#!/bin/bash

# Script Name: xscript.sh
# Description: A modified tool of xssh with executing previous commands capabilities.
# Author: Chestnut

xcmd_usage() {
  # Help message
  echo "usage: xcmd [-u <user>] [-p <passwd>] <ip-string> [cmd]"
  echo "   "
  echo "  -u | --user              : Login user"
  echo "  -p | --password          : Login password"
  echo "  -h | --help              : Show this message"
}

xcmd() {
  # Parse args
  # set defaults
  local user=$(get_config '.connect.xcmd.user')
  local pass=$(get_config '.connect.xcmd.password')
  local cmd=$(get_config '.connect.xcmd.command')
  local options=($(get_config '.connect.xcmd.options | join(" ")'))
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
      xcmd_usage
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
  [ -n "$2" ] && cmd="${@:2}"
  # validate required args
  if [ -z "${ip}" ]; then
    echo "Missing required argument '<ip-string>'." 
    xcmd_usage
    return 1
  fi

  #Execute
  if [ -z "$cmd" ]; then
    echo "ssh "${options[@]}" $user@$ip"
    sshpass -p "$pass" ssh -t "${options[@]}" "$user"@"$ip"
  else
    echo "ssh "${options[@]}" $user@$ip $cmd"
    sshpass -p "$pass" ssh -t "${options[@]}" "$user"@"$ip" "$cmd"
  fi
}
