#!/usr/bin/env bash

# shellcheck source-path=shell
. "${SHELL_DIR}/lib/core/logger.sh"
. "${SHELL_DIR}/lib/core/command.sh"

runner.run() {
    local command="${1}"
    shift
    local args=("${@}")

    log.debug "Entering runner.run wrapper..."

    local runner_log_file
    runner_log_file="$(mktemp "${LOG_DIR}/runner.XXXXXX")"
    log.debug "Logging into: ${runner_log_file}"

    local command_log_file
    command_log_file="$(mktemp "${LOG_DIR}/command.XXXXXX")"
    log.debug "Logging into: ${command_log_file}"

    set -eEo pipefail
    trap 'runner.catch_error $?' ERR
    {
        log.debug "Running command: ${command} ${args[*]}"
        "${command}" "${args[@]}" | tee "${command_log_file}"
    } 1>&2 | tee "${runner_log_file}"

    rm -f "${runner_log_file}"
    trap - ERR

    local exit_code
    exit_code=$(runner.get_exit_code "${command_log_file}")
    rm -f "${command_log_file}"
    log.debug "Exit code: ${exit_code}"

    return "${exit_code}"
}

runner.get_exit_code() {
    local log_file="${1}"

    local exit_code="${COMMAND_SUCCESS}"

    while IFS= read -r line; do
        if [[ "${line}" == "${COMMAND_WARNING}" && "${exit_code}" == "${COMMAND_SUCCESS}" ]]; then
            log.debug "Found warning in log file: ${log_file}"
            exit_code="${COMMAND_WARNING}"
        elif [[ "${line}" == "${COMMAND_ERROR}" && "${exit_code}" == "${COMMAND_SUCCESS}" ]]; then
            log.debug "Found error in log file: ${log_file}"
            exit_code="${COMMAND_ERROR}"
        fi
    done < "${log_file}"

    echo "${exit_code}"
}

runner.catch_error() {
    local status_code="${1}"

    log.error "Error caught with status code: ${status_code}"
    runner.print_callstack

    exit "${COMMAND_ERROR}"
}

runner.print_callstack() {
    local stack_size=${#FUNCNAME[@]}
    local indent=""
    local -i i
    local starting=2

    log.error "Callstack is:"
    for ((i=starting; i<stack_size; i++)); do
        local func="${FUNCNAME[i]:-(top level)}"
        local -i line="${BASH_LINENO[$((i - 1))]}"
        local src="${BASH_SOURCE[${i}]:-(no file)}"
        log.error "${indent}˪${src}:${line} (${func})"
        indent="${indent}  "
    done
}
