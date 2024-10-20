#!/bin/bash

# Script Name: xrsync.sh
# Description: A modified tool of rsync.
# Author: Chestnut

xrsyncu_usage() {
  # Help message
  echo "usage: xrsyncu [-u <user>] [-p <passwd>] <ip-string> <src> [dest]"
  echo "   "
  echo "  -u | --user              : Login user"
  echo "  -p | --password          : Login password"
  echo "  -h | --help              : Show this message"
}

xrsyncu() {
  # Parse args
  # set defaults
  local user=$(get_config '.sync.xrsyncu.user')
  local pass=$(get_config '.sync.xrsyncu.password')
  local dest=$(get_config '.sync.xrsyncu.destination')
  local options=$(get_config '.sync.xrsyncu.options | join(" ")')
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
      xrsyncu_usage
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
  local src=$(get_path "$2")
  [ -n "$3" ] && dest="$3"
  # validate required args
  if [ -z "${ip}" ]; then
    echo "Missing required argument '<ip-string>'." 
    xrsyncu_usage
    return 1
  fi
  if [ -z "${src}" ]; then
    echo "Missing required argument '<src>'." 
    xscpu_usage
    return 1
  fi

  # Execute
  echo "rsync $options $src $user@$ip:$dest"
  sshpass -p "$pass" rsync $options "$src" "$user"@"$ip":"$dest" &>/dev/null
}

xrsyncd_usage() {
  # Help message
  echo "usage: xrsyncd [-u <user>] [-p <passwd>] <ip-string> <src> [dest]"
  echo "   "
  echo "  -u | --user              : Login user"
  echo "  -p | --password          : Login password"
  echo "  -h | --help              : Show this message"
}

xrsyncd() {
  # Parse args
  # set defaults
  local user=$(get_config '.sync.xrsyncd.user')
  local pass=$(get_config '.sync.xrsyncd.password')
  local dest=$(get_config '.sync.xrsyncd.destination')
  local options=$(get_config '.sync.xrsyncd.options | join(" ")')
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
      xrsyncd_usage
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
  local src="$2"
  [ -n "$3" ] && dest=$(realpath "$3")
  # validate required args
  if [ -z "${ip}" ]; then
    echo "Missing required argument '<ip-string>'." 
    xrsyncd_usage
    return 1
  fi
  if [ -z "${src}" ]; then
    echo "Missing required argument '<src>'." 
    xscpu_usage
    return 1
  fi

  # Execute
  echo "rsync $options $user@$ip:$src $dest"
  sshpass -p "$pass" rsync $options "$user"@"$ip":"$src" "$dest" &>/dev/null
}
