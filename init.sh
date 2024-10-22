#!/bin/bash

# Script Name: init.sh
# Description: Entry of xtool.
# Usage: source /path/to/init.sh
# Author: Chestnut

_source_files() {
  # Arguments
  local directory="$1"
  # Execute
  while IFS= read -r file; do
    source "$file"
  done < <(find "$directory" -type f -name "*.sh")
}

# Config file
export XTOOL_ROOT="$(dirname "$0")"

# Source files
_source_files "$(dirname "$0")/common"
_source_files "$(dirname "$0")/connect"
_source_files "$(dirname "$0")/sync"
_source_files "$(dirname "$0")/file_system"
_source_files "$(dirname "$0")/execute"
_source_files "$(dirname "$0")/business"

