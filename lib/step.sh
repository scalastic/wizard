#!/usr/bin/env bash

set -euo pipefail

DEFAULT_DEFINITION_PATH="config/default/step-default.json"

get_step_definition() {

    local step=${1:-}

    specific_definition_path="config/default/step-default-${step}.json"

    if [[ -f "$specific_definition_path" ]]; then
        echo "$specific_definition_path"
        return
    else 
        echo "$DEFAULT_DEFINITION_PATH"
        return
    fi
}