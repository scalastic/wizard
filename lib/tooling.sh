#!/usr/bin/env bash

set -euo pipefail

tooling::_check_command() {
    debug "Check command $1"

    [ -x "$(command -v "$1")" ] && echo true || echo false
}

tooling::_get_command() {
    debug "Get command $1"

    command -v "$1"
}

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
