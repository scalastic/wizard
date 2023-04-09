#!/usr/bin/env bash
#
# Logger functions for bash scripts

set -euo pipefail

# shellcheck disable=SC2034
LOG_LEVEL_DEBUG=0
# shellcheck disable=SC2034
LOG_LEVEL_INFO=1
# shellcheck disable=SC2034
LOG_LEVEL_WARN=2
# shellcheck disable=SC2034
LOG_LEVEL_ERROR=3
# shellcheck disable=SC2034
LOG_LEVEL_FATAL=4

# shellcheck disable=SC2034
LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

# shellcheck disable=SC2034
LOG_LEVELS=(DEBUG INFO WARN ERROR FATAL)

# shellcheck disable=SC2034
LOG_LEVEL_DEBUG_COLOR="\e[0;34m"
# shellcheck disable=SC2034
LOG_LEVEL_INFO_COLOR="\e[0;32m"
# shellcheck disable=SC2034
LOG_LEVEL_WARN_COLOR="\e[0;33m"
# shellcheck disable=SC2034
LOG_LEVEL_ERROR_COLOR="\e[0;31m"
# shellcheck disable=SC2034
LOG_LEVEL_FATAL_COLOR="\e[0;35m"

# shellcheck disable=SC2034
LOG_COLOR_OFF="\e[0m"

#######################################
# Log a message.
# Globals:
#   LOG_LEVEL (read-only)
#   LOG_LEVELS (read-only)
# Arguments:
#   level: log level
#   message: message to log
#   color: color to use for the message
#   color_off: color to use to turn off the color
# Outputs:
#   Redirects and writes the message to stderr and file log/stdout.log 
#######################################
log() {
    local level=$1
    local message=$2
    local color=$3
    local color_off=$4
    if [ "$LOG_LEVEL" -le "$level" ]; then
        echo -e "${color}[${LOG_LEVELS[$level]}] $message${color_off}" >&2 | tee -a log/stdout.log > /dev/null
    fi
}

#######################################
# Log a debug message.
# Globals:
#   LOG_LEVEL_DEBUG (read-only)
#   LOG_LEVEL_DEBUG_COLOR (read-only)
#   LOG_LEVEL_DEBUG_COLOR_OFF (read-only)
# Arguments:
#   message: message to log
# Outputs:
#   Writes the debug message to stdout
#######################################
debug() {
    log "$LOG_LEVEL_DEBUG" "[${FUNCNAME[1]}] $1" "$LOG_LEVEL_DEBUG_COLOR" "$LOG_COLOR_OFF"
}

#######################################
# Log an info message.
# Globals:
#   LOG_LEVEL_INFO (read-only)
#   LOG_LEVEL_INFO_COLOR (read-only)
#   LOG_LEVEL_INFO_COLOR_OFF (read-only)
# Arguments:
#   message: message to log
# Outputs:
#   Writes the info message to stdout
#######################################
info() {
    log "$LOG_LEVEL_INFO" "$1" "$LOG_LEVEL_INFO_COLOR" "$LOG_COLOR_OFF"
}

#######################################
# Log a warning message.
# Globals:
#   LOG_LEVEL_WARN (read-only)
#   LOG_LEVEL_WARN_COLOR (read-only)
#   LOG_LEVEL_WARN_COLOR_OFF (read-only)
# Arguments:
#   message: message to log
# Outputs:
#   Writes the warning message to stdout
#######################################
warn() {
    log "$LOG_LEVEL_WARN" "$1" "$LOG_LEVEL_WARN_COLOR" "$LOG_COLOR_OFF"
}

#######################################
# Log an error message.
# Globals:
#   LOG_LEVEL_ERROR (read-only)
#   LOG_LEVEL_ERROR_COLOR (read-only)
#   LOG_LEVEL_ERROR_COLOR_OFF (read-only)
# Arguments:
#   message: message to log
# Outputs:
#   Writes the error message to stdout
#######################################
error() {
    log "$LOG_LEVEL_ERROR" "$1" "$LOG_LEVEL_ERROR_COLOR" "$LOG_COLOR_OFF" >&2
}

#######################################
# Log a fatal message.
# Globals:
#   LOG_LEVEL_FATAL (read-only)
#   LOG_LEVEL_FATAL_COLOR (read-only)
#   LOG_LEVEL_FATAL_COLOR_OFF (read-only)
# Arguments:
#   message: message to log
# Outputs:
#   Writes the fatal message to stdout
#######################################
fatal() {
    log "$LOG_LEVEL_FATAL" "$1" "$LOG_LEVEL_FATAL_COLOR" "$LOG_COLOR_OFF" >&2
}
