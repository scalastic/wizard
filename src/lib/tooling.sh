#!/usr/bin/env bash
# @desc Tooling library for bash scripts

set -euo pipefail

#@desc      Check if a command exists
#@ex        tooling::_check_command jq
#@arg       The command to check
#@stdout    true if the command exists otherwise false
tooling::_check_command() {
    log::debug "Check command $1"

    if [ -x "$(command -v "$1")" ]; then { true; } else { false; } fi
}

##desc      Get the path of a command
#@ex        tooling::_get_command jq
#@arg       The command to get the path
#@stdout    The path of the command
tooling::_get_command() {
    log::debug "Get command $1"

    command -v "$1"
}

#@desc      Set the jq command
#@ex        tooling::set_jq
#@const     JQ Set with the jq command if it exists otherwise with the dockerized jq command (write)
#@const     IS_DOCKERIZED_JQ Set to true if the jq command is dockerized otherwise false (write)
#@status    1 if no jq command is found
tooling::set_jq() {
    log::debug "Set jq tool"

    if tooling::_check_command jq; then
        # shellcheck disable=SC2155
        export JQ="$(tooling::_get_command jq)"
        export IS_DOCKERIZED_JQ=false
        log::info "Using jq command $JQ"

    elif tooling::_check_command docker; then
        # shellcheck disable=SC2155
        export JQ="$(tooling::_get_command docker) run -i scalastic/wild:latest"
        export IS_DOCKERIZED_JQ=true
        log::info "Using dockerized jq command $JQ"

    else
        log::fatal "No jq command found! Please install jq or docker."
        exit 1

    fi
}
