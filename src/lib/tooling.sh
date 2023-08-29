#!/usr/bin/env bash
# @desc Tooling library for bash scripts

set -euo pipefail

source "./src/lib/platform.sh"

#@desc      Check if a command exists
#@ex        tooling__check_command jq
#@arg       The command to check
#@stdout    true if the command exists otherwise false
tooling__check_command() {
    log_debug "Check command $1"

    if [ -x "$(command -v "$1")" ]; then { true; } else { false; } fi
}

##desc      Get the path of a command
#@ex        tooling__get_command jq
#@arg       The command to get the path
#@stdout    The path of the command
tooling__get_command() {
    log_debug "Get command $1"

    command -v "$1"
}

#@desc      Set the jq command
#@ex        tooling_set_jq
#@const     JQ Set with the jq command if it exists otherwise with the dockerized jq command (write)
#@const     IS_DOCKERIZED_JQ Set to true if the jq command is dockerized otherwise false (write)
#@status    1 if no jq command is found
tooling_set_jq() {
    log_debug "Set jq tool"

    if tooling__check_command jq; then
        # shellcheck disable=SC2155
        export JQ="$(tooling__get_command jq)"
        export IS_DOCKERIZED_JQ=false
        log_info "Using jq command $JQ"

    elif tooling__check_command docker; then
        # shellcheck disable=SC2155
        export JQ="$(tooling__get_command docker) run -i scalastic/wild:latest"
        export IS_DOCKERIZED_JQ=true
        log_info "Using dockerized jq command $JQ"

    else
        log_fatal "No jq command found! Please install jq or docker."
        exit 1

    fi
}

tooling_get_ip() {
  local ip_address=''

  if platform_is_macos; then
    ip_address=$(ifconfig en0 | grep 'inet ' | cut -d' ' -f2 | awk '{print $1}')
  fi

   echo "$ip_address"
}
