#!/usr/bin/env bash

set -euo pipefail

#######################
# Check if a command exists
# Globals:
#   None
# Arguments:
#   The command to check
# Returns:
#   true or false
#######################
tooling::_check_command() {
    debug "Check command $1"

    [ -x "$(command -v "$1")" ] && echo true || echo false
}

#######################
# Get the path of a command
# Globals:
#   None
# Arguments:
#   The command to get the path
# Returns:
#   The path of the command
#######################
tooling::_get_command() {
    debug "Get command $1"

    command -v "$1"
}

#######################
# Set the jq tool
# Globals:
#   JQ point to the jq command
#   IS_DOCKERIZED_JQ true if the jq command is dockerized otherwise false
# Arguments:
#   None
# Returns:
#   None
#######################
tooling::set_jq_tool() {
    debug "Set jq tool"

    if [ "$(tooling::_check_command jq)" = "true" ]; then
        # shellcheck disable=SC2155
        export JQ="$(tooling::_get_command jq)"
        export IS_DOCKERIZED_JQ=false
        info "Using jq command $JQ"

    elif [ "$(tooling::_check_command docker)" = "true" ]; then
        # shellcheck disable=SC2155
        export JQ="$(tooling::_get_command docker) run -i scalastic/wild:latest"
        export IS_DOCKERIZED_JQ=true
        info "Using dockerized jq command $JQ"

    else
        fatal "Missing minimal required commands for jq"
        exit 1

    fi
}
