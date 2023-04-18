#!/usr/bin/env bash
#@lib 
#@desc Logger functions for bash scripts


set -euo pipefail

#######################################
#@const
#@desc Constant that stores log level debug definition.
#######################################
LOG_LEVEL_DEBUG=0

#######################################
#@const
#@desc Constant that stores log level info definition.
#######################################
LOG_LEVEL_INFO=1

#######################################
#@const
#@desc Constant that stores log level warn definition.
#######################################
LOG_LEVEL_WARN=2

#######################################
#@const
#@desc Constant that stores log level error definition.
#######################################
LOG_LEVEL_ERROR=3

#######################################
#@const
#@desc Constant that stores log level fatal (bazooka) definition.
#######################################
LOG_LEVEL_FATAL=4

#######################################
#@const
#@desc Constant that stores current log level.
#######################################
LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

#######################################
#@const
#@desc Array constant that stores all log level definitions.
#######################################
LOG_LEVELS=(DEBUG INFO WARN ERROR FATAL)

#######################################
#@const
#@desc Constant that stores log level debug color definition.
#######################################
LOG_LEVEL_DEBUG_COLOR="\e[0;34m"

#######################################
#@const
#@desc Constant that stores log level info color definition.
#######################################
LOG_LEVEL_INFO_COLOR="\e[0;32m"

#######################################
#@const
#@desc Constant that stores log level warn color definition.
#######################################
LOG_LEVEL_WARN_COLOR="\e[0;33m"

#######################################
#@const
#@desc Constant that stores log level error color definition.
#######################################
LOG_LEVEL_ERROR_COLOR="\e[0;31m"

#######################################
#@const
#@desc Constant that stores log level fatal color definition.
#######################################
LOG_LEVEL_FATAL_COLOR="\e[0;35m"

#######################################
#@const
#@desc Constant that stores log level color off definition.
#######################################
LOG_COLOR_OFF="\e[0m"

#######################################
#@desc Log a message.
#@example _log \\"$LOG_LEVEL_DEBUG\\" \\"This is a debug message\\" \\"$LOG_LEVEL_DEBUG_COLOR\\" \\"$LOG_COLOR_OFF\\"
# Globals:
#@const    LOG_LEVEL (read-only)
#@const    LOG_LEVELS (read-only)
#@const    LOG_LEVEL_DEBUG_COLOR (read-only)
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
#@visu private
#@example _banner \\"This is a banner message\\" \\"$LOG_LEVEL_INFO_COLOR\\" \\"$LOG_COLOR_OFF\\"
#@desc Log a banner message.
# Globals:
#@const   LOG_LEVEL_INFO (read-only)
#@const   LOG_LEVEL_INFO_COLOR (read-only)
#@const   LOG_COLOR_OFF (read-only)
# Arguments:
#@arg   message: message to log
#@arg   color: color to use for the message
#@arg   color_off: color to use to turn off the color
# Outputs:
#@stdout   Writes the banner message to stdout
#######################################
_banner() {
    local message=$1
    local color=$2
    local color_off=$3
    echo -e "${color}#######################################################################${color_off}" >&2 | tee -a log/stdout.log >/dev/null
    echo -e "${color} $message${color_off}" >&2 | tee -a log/stdout.log >/dev/null
    echo -e "${color}#######################################################################${color_off}" >&2 | tee -a log/stdout.log >/dev/null
}

#######################################
#@desc Log a debug message.
#@example log::debug \\"This is a debug message\\"
# Globals:
#@const   LOG_LEVEL_DEBUG (read-only)
#@const   LOG_LEVEL_DEBUG_COLOR (read-only)
#@const   LOG_COLOR_OFF (read-only)
# Arguments:
#@arg   message: message to log
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

#######################################
#@desc Log an info message.
#@example log::info \\"This is an info message\\" 
# Globals:
#@const   LOG_LEVEL_INFO (read-only)
#@const   LOG_LEVEL_INFO_COLOR (read-only)
#@const   LOG_COLOR_OFF (read-only)
# Arguments:
#@arg   message: message to log
# Outputs:
#@stdout   Writes the info message to stdout
#######################################
log::info() {
    _log "$LOG_LEVEL_INFO" "$1" "$LOG_LEVEL_INFO_COLOR" "$LOG_COLOR_OFF"
}

#######################################
#@desc Log a warning message.
#@example log::warn \\"This is a warning message\\"
# Globals:
#@const   LOG_LEVEL_WARN (read-only)
#@const   LOG_LEVEL_WARN_COLOR (read-only)
#@const   LOG_COLOR_OFF (read-only)
# Arguments:
#@arg   message: message to log
# Outputs:
#@stdout   Writes the warning message to stdout
#######################################
log::warn() {
    _log "$LOG_LEVEL_WARN" "$1" "$LOG_LEVEL_WARN_COLOR" "$LOG_COLOR_OFF"
}

#######################################
#@desc Log an error message.
#@example log::error \\"This is an error message\\"
# Globals:
#@const   LOG_LEVEL_ERROR (read-only)
#@const   LOG_LEVEL_ERROR_COLOR (read-only)
#@const   LOG_COLOR_OFF (read-only)
# Arguments:
#@arg   message: message to log
# Outputs:
#@stdout   Writes the error message to stdout
#######################################
log::error() {
    _log "$LOG_LEVEL_ERROR" "$1" "$LOG_LEVEL_ERROR_COLOR" "$LOG_COLOR_OFF" >&2
}

#######################################
#@desc Log a fatal message.
#@example log::fatal \\"This is a fatal message\\"
# Globals:
#@const   LOG_LEVEL_FATAL (read-only)
#@const   LOG_LEVEL_FATAL_COLOR (read-only)
#@const   LOG_COLOR_OFF (read-only)
# Arguments:
#@arg   message: message to log
# Outputs:
#@stdout   Writes the fatal message to stdout
#######################################
log::fatal() {
    _log "$LOG_LEVEL_FATAL" "$1" "$LOG_LEVEL_FATAL_COLOR" "$LOG_COLOR_OFF" >&2
}

#######################################
#@desc Log a banner message.
#@example log::banner \\"This is a banner message\\"
# Globals:
#@const   LOG_LEVEL_INFO_COLOR (read-only)
#@const   LOG_COLOR_OFF (read-only)
# Arguments:
#@arg   message: message to log
# Outputs:
#@stdout   Writes the banner message to stdout
#######################################
log::banner() {
    _banner "$*" "$LOG_LEVEL_INFO_COLOR" "$LOG_COLOR_OFF"
}
