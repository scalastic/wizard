#!/usr/bin/env bash

# shellcheck source-path=shell
. "${SHELL_DIR}/lib/core/logger.sh"

# shellcheck disable=SC2034
COMMAND_SUCCESS=0
# shellcheck disable=SC2034
COMMAND_WARNING=1
# shellcheck disable=SC2034
COMMAND_ERROR=2

command.run_function() {
    local function_name="$1"
    shift
    local args=("$@")

    if declare -f "${function_name}" > /dev/null; then
        log.debug "Running function: ${function_name} with args: ${args[*]}"
        ${function_name} "${args[@]}"
    else
        log.error "Function ${function_name} is not defined"
        return 1
    fi
}

command.run_eval() {
    local command="$1"

    log.debug "Running eval for command: ${command}"
    eval "${command}"
}