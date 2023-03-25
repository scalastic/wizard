#!/usr/bin/env bash

set -euo pipefail

set_jq_tool() {
    if [ -x "$(command -v jq)" ]; then
        echo 'Using jq command'
        JQ="$(command -v jq)"
        IS_DOCKERIZED_JQ=false
    elif [ -x "$(command -v docker)" ]; then
        echo 'Using docker command'
        # shellcheck disable=SC2034
        JQ="$(command -v docker) run -i scalastic/wild:latest"
        # shellcheck disable=SC2034
        IS_DOCKERIZED_JQ=true
    else 
        echo "Error: missing minimal required commands for jq"
    fi
}