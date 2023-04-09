#!/usr/bin/env bash

set -euo pipefail

set_jq_tool() {
    debug "Set jq tool"

    if [ -x "$(command -v jq)" ]; then
        # shellcheck disable=SC2155
        export JQ="$(command -v jq)"
        export IS_DOCKERIZED_JQ=false
        info "Using jq command $JQ"

    elif [ -x "$(command -v docker)" ]; then

        # shellcheck disable=SC2155
        export JQ="$(command -v docker) run -i scalastic/wild:latest"
        export IS_DOCKERIZED_JQ=true
        info "Using dockerized jq command $JQ"

    else

        fatal "Missing minimal required commands for jq"
        exit 1

    fi
}
