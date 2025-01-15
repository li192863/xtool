#!/bin/bash

# Script Name: xscp.sh
# Description: A modified tool of scp.
# Author: Chestnut

xscpu_usage() {
  # Help message
  echo "usage: xscpu [-u <user>] [-p <passwd>] <ip-string> <src>... <dest>"
  echo "   "
  echo "  -u | --user              : Login user"
  echo "  -p | --password          : Login password"
  echo "  -h | --help              : Show this message"
}

xscpu() {
  # Parse args
  # set defaults
  local user=$(get_config '.sync.xscpu.user')
  local pass=$(get_config '.sync.xscpu.password')
  local options=($(get_config '.sync.xscpu.options | join(" ")'))
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
      xscpu_usage
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
  local src=($(get_params_slice 1 -1 "get_path " "" "${args[@]}"))
  local dest=${args[${#args[@]}]}
  # validate required args
  if [ -z "${ip}" ]; then
    echo "Missing required argument '<ip-string>'."
    xscpu_usage
    return 1
  fi
  if [ -z "${src}" ]; then
    echo "Missing required argument '<src>'."
    xscpu_usage
    return 1
  fi

  # Execute
  local cmd="sshpass -p \"${pass}\" scp ${options[@]} ${src[@]} \"${user}\"@\"${ip}\":\"${dest}\""
  echo "${cmd}"
  eval "${cmd}"
}

xscpd_usage() {
  # Help message
  echo "usage: xscpd [-u <user>] [-p <passwd>] <ip-string> <src>... <dest>"
  echo "   "
  echo "  -u | --user              : Login user"
  echo "  -p | --password          : Login password"
  echo "  -h | --help              : Show this message"

}

xscpd() {
  # Parse args
  # set defaults
  local user=$(get_config '.sync.xscpd.user')
  local pass=$(get_config '.sync.xscpd.password')
  local options=($(get_config '.sync.xscpd.options | join(" ")'))
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
      xscpd_usage
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
  local src=($(get_params_slice 1 -1 "echo \"${user}\"@\"${ip}\":" "" "${args[@]}"))
  local dest=${args[${#args[@]}]}
  # validate required args
  if [ -z "${ip}" ]; then
    echo "Missing required argument '<ip-string>'."
    xscpd_usage
    return 1
  fi
  if [ -z "${src}" ]; then
    echo "Missing required argument '<src>'."
    xscpu_usage
    return 1
  fi

  # Execute
  local cmd="sshpass -p \"${pass}\" scp ${options[@]} ${src[@]} \"${dest}\""
  echo "${cmd}"
  eval "${cmd}"
}