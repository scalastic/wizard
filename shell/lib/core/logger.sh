#!/usr/bin/env bash


DEBUG_LEVEL=0
INFO_LEVEL=1
WARN_LEVEL=2
ERROR_LEVEL=3
SUCCESS_LEVEL=4

LOG_LEVELS=(DEBUG INFO WARN ERROR SUCCESS)
LOG_LEVEL=${LOG_LEVEL:-INFO_LEVEL}

START_COLOR_PREFIX="\033[0;"
START_COLOR_SUFFIX="m"
END_COLOR="\033[0m"

DEBUG_COLOR="${START_COLOR_PREFIX}30${START_COLOR_SUFFIX}"
INFO_COLOR="${START_COLOR_PREFIX}34${START_COLOR_SUFFIX}"
WARN_COLOR="${START_COLOR_PREFIX}33${START_COLOR_SUFFIX}"
ERROR_COLOR="${START_COLOR_PREFIX}31${START_COLOR_SUFFIX}"
SUCCESS_COLOR="${START_COLOR_PREFIX}32${START_COLOR_SUFFIX}"

log.is_color_enabled() {
    if which tput > /dev/null 2>&1 && [[ $(tput -T$TERM colors) -ge 8 ]]; then
        return 0
    else
        return 1
    fi
}

log.debug() {
    local function_name

    if [ -n "${FUNCNAME:-}" ] && [ "${#FUNCNAME[@]}" -gt 1 ]; then
        function_name="${FUNCNAME[1]}"
    else
        function_name="unknown function"
    fi

    if [ -n "$1" ]; then
        log.__log "${DEBUG_COLOR}" "${DEBUG_LEVEL}" "(${function_name}) $1"
    else
        log.__stream "${DEBUG_COLOR}" "(${function_name})${DEBUG_LEVEL}"
    fi
}

log.info() {
    if [ -n "$1" ]; then
        log.__log "${INFO_COLOR}" "${INFO_LEVEL}" "$1"
    else
        log.__stream "${INFO_COLOR}" "${INFO_LEVEL}"
    fi
}

log.warn() {
    if [ -n "$1" ]; then
        log.__log "${WARN_COLOR}" "${WARN_LEVEL}" "$1"
    else
        log.__stream "${WARN_COLOR}" "${WARN_LEVEL}"
    fi
}

log.error() {
    if [ -n "$1" ]; then
        log.__log "${ERROR_COLOR}" "${ERROR_LEVEL}" "$1"
    else
        log.__stream "${ERROR_COLOR}" "${ERROR_LEVEL}"
    fi
}

log.success() {
    if [ -n "$1" ]; then
        log.__log "${SUCCESS_COLOR}" "${SUCCESS_LEVEL}" "$1"
    else
        log.__stream "${SUCCESS_COLOR}" "${SUCCESS_LEVEL}"
    fi
}

log.__log() {
    local color="$1"
    local level="$2"
    local message="$3"

    [ ! -d "${LOG_DIR}" ] && mkdir -p "${LOG_DIR}"

    if [ -n "${level}" ] && [ "${level}" -ge "${LOG_LEVEL}" ]; then
        level="[${LOG_LEVELS[${level}]}]"

        if log.is_color_enabled; then
            printf "%b%s %s%b\n" "${color}" "${level}" "${message}" "${END_COLOR}" | tee -a "${LOG_DIR}/stderr.log" >&2
        else
            printf "%s %s\n" "${level}" "${message}" | tee -a "${LOG_DIR}/stderr.log" >&2
        fi
    elif [ -z "${level}" ]; then
        printf "%s\n" "${message}" | tee -a "${LOG_DIR}/stderr.log" >&2
    fi
}

log.__stream() {
    local color="$1"
    local level="$2"

    while IFS= read -r line; do
        log.__log "${color}" "${level}" "${line}"
    done
}
