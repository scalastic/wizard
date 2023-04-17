#!/usr/bin/env bash
#@lib 
#@desc This script is used to test documentation generation for bash scripts used in Wild.


set -euo pipefail

#######################################
#@const
#@desc Constant that stores log level debug definition.
#######################################
# shellcheck disable=SC2034
LOG_LEVEL_DEBUG=0

#######################################
#@const
#@desc Constant that stores current log level.
#######################################
# shellcheck disable=SC2034
LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

#######################################
#@const
#@desc Constant that stores all log level definitions.
#######################################
# shellcheck disable=SC2034
LOG_LEVELS=(DEBUG INFO WARN ERROR FATAL)

#######################################
#@const
#@desc Constant that stores log level debug color definition.
#######################################
# shellcheck disable=SC2034
LOG_LEVEL_DEBUG_COLOR="\e[0;34m"

#######################################
#@const
#@desc Constant that stores log level color off definition.
#######################################
# shellcheck disable=SC2034
LOG_COLOR_OFF="\e[0m"

#######################################
#@desc Log a message.
#@example _log \\"$LOG_LEVEL_DEBUG\\" \\"This is a debug message\\" \\"$LOG_LEVEL_DEBUG_COLOR\\" \\"$LOG_COLOR_OFF\\"
# Globals:
#@const    LOG_LEVEL read-only
#@const    LOG_LEVELS read-only
#@const    LOG_LEVEL_DEBUG_COLOR read-only
# Arguments:
#@arg      level: log level
#@arg      message: message to log
#@arg      color: color to use for the message
#@arg      color_off: color to use to turn off the color
# Outputs:
#@sdtout   Redirects and writes the message to stderr and file log/stdout.log
#######################################
_log() {
    local level=$1
    local message=$2
    local color=$3
    local color_off=$4
    if [ "$LOG_LEVEL" -le "$level" ]; then
        echo -e "${color}[${LOG_LEVELS[$level]}] $message${color_off}" >&2 | tee -a log/stdout.log >/dev/null
    fi
}

#######################################
#@desc Log a debug message.
#@example log::debug \\"This is a debug message\\"
# Globals:
#@const    LOG_LEVEL_DEBUG (read-only)
#@const    LOG_LEVEL_DEBUG_COLOR (read-only)
#@const    LOG_COLOR_OFF (read-only)
# Arguments:
#@arg      message: message to log
# Outputs:
#@stdout   Writes the debug message to stdout
#######################################
log::debug() {
    local function_name

    [ -v FUNCNAME ] && [ "${#FUNCNAME[@]}" -gt 1 ] && \
        function_name="${FUNCNAME[1]}" || \
        function_name="unknown function"

    _log "$LOG_LEVEL_DEBUG" "[${function_name}] $1" "$LOG_LEVEL_DEBUG_COLOR" "$LOG_COLOR_OFF"
}
