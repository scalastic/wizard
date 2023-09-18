#!/usr/bin/env bash
#@desc Logger functions for bash scripts


set -euo pipefail


#@desc Constant that stores log level debug definition.
declare -r LOG_LEVEL_DEBUG=0

#@desc Constant that stores log level info definition.
declare -r LOG_LEVEL_INFO=1

#@desc Constant that stores log level warn definition.
declare -r LOG_LEVEL_WARN=2

#@desc Constant that stores log level error definition.
declare -r LOG_LEVEL_ERROR=3

#@desc Constant that stores log level fatal (bazooka) definition.
declare -r LOG_LEVEL_FATAL=4

#@desc Constant that stores current log level.
declare LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

#@desc Array constant that stores all log level definitions.
declare -r LOG_LEVELS=(DEBUG INFO WARN ERROR FATAL)

#@desc Constant that stores log level debug color definition.
declare -r LOG_LEVEL_DEBUG_COLOR="\e[0;34m"

#@desc Constant that stores log level info color definition.
declare -r LOG_LEVEL_INFO_COLOR="\e[0;32m"

#@desc Constant that stores log level warn color definition.
declare -r LOG_LEVEL_WARN_COLOR="\e[0;33m"

#@desc Constant that stores log level error color definition.
declare -r LOG_LEVEL_ERROR_COLOR="\e[0;31m"

#@desc Constant that stores log level fatal color definition.
declare -r LOG_LEVEL_FATAL_COLOR="\e[0;35m"

#@desc Constant that stores log level color off definition.
declare -r LOG_COLOR_OFF="\e[0m"

log__prerequisite() {
  local status=0

  if [ -z "$LOG_PATH" ]; then
    status=$((status + 1))
  fi

  if [ ! -d "$LOG_PATH" ] && ! mkdir -p "$LOG_PATH"; then
    status=$((status + 1))
  fi

  return "$status"
}

#@desc      Log a message.
#@ex        log__log \"$LOG_LEVEL_DEBUG\" \"This is a debug message\" \"$LOG_LEVEL_DEBUG_COLOR\" \"$LOG_COLOR_OFF\"
#@const     LOG_LEVEL (read-only)
#@const     LOG_LEVELS (read-only)
#@const     LOG_LEVEL_DEBUG_COLOR (read-only)
#@arg       level: log level
#@arg       message: message to log
#@arg       color: color to use for the message
#@arg       color_off: color to use to turn off the color
#@stdout    Redirects and writes the message to stderr and file log/stdout.log
log__log() {
    local level=$1
    local message=$2
    local color=$3
    local color_off=$4

    if ! log__prerequisite; then
      return 2
    fi

    if [ "$LOG_LEVEL" -le "$level" ]; then
        #echo -e "${color}[${LOG_LEVELS[$level]}] $message${color_off}" | tee -a "${LOG_PATH}/stdout.log" >&2
        printf "%b[%s] %s%b\n" "$color" "${LOG_LEVELS[$level]}" "$message" "$color_off" | tee -a "${LOG_PATH}/stdout.log" >&2
    fi
}


#@desc      Log a banner message.
#@ex        log__banner \"This is a banner message\" \"$LOG_LEVEL_INFO_COLOR\" \"$LOG_COLOR_OFF\"
#@const     LOG_LEVEL_INFO (read-only)
#@const     LOG_LEVEL_INFO_COLOR (read-only)
#@const     LOG_COLOR_OFF (read-only)
#@arg       message: message to log
#@arg       color: color to use for the message
#@arg       color_off: color to use to turn off the color
#@stdout    Writes the banner message to stdout
log__banner() {
    local message=$1
    local color=$2
    local color_off=$3

    if ! log__prerequisite; then
      return 2
    fi

    #echo -e "${color}################################${color_off}" | tee -a "${LOG_PATH}/stdout.log" >&2
    #echo -e "${color} $message${color_off}" | tee -a "${LOG_PATH}/stdout.log" >&2
    #echo -e "${color}################################${color_off}" | tee -a "${LOG_PATH}/stdout.log" >&2

    printf "%b################################%b\n" "$color" "$color_off" | tee -a "${LOG_PATH}/stdout.log" >&2
    printf "%b %s%b\n" "$color" "$message" "$color_off" | tee -a "${LOG_PATH}/stdout.log" >&2
    printf "%b################################%b\n" "$color" "$color_off" | tee -a "${LOG_PATH}/stdout.log" >&2

}


#@desc      Log a debug message.
#@ex        log_debug \"This is a debug message\"
#@const     LOG_LEVEL_DEBUG (read-only)
#@const     LOG_LEVEL_DEBUG_COLOR (read-only)
#@const     LOG_COLOR_OFF (read-only)
#@arg       message: message to log
#@stdout    Writes the debug message to stdout
log_debug() {
    local function_name

    [ -v FUNCNAME ] && [ "${#FUNCNAME[@]}" -gt 1 ] && \
        function_name="${FUNCNAME[1]}" || \
        function_name="unknown function"

    log__log "$LOG_LEVEL_DEBUG" "[${function_name}] $1" "$LOG_LEVEL_DEBUG_COLOR" "$LOG_COLOR_OFF"
}


#@desc      Log an info message.
#@ex        log_info \"This is an info message\"
#@const     LOG_LEVEL_INFO (read-only)
#@const     LOG_LEVEL_INFO_COLOR (read-only)
#@const     LOG_COLOR_OFF (read-only)
#@arg       message: message to log
#@stdout    Writes the info message to stdout
log_info() {
    log__log "$LOG_LEVEL_INFO" "$1" "$LOG_LEVEL_INFO_COLOR" "$LOG_COLOR_OFF"
}


#@desc      Log a warning message.
#@ex        log_warn \"This is a warning message\"
#@const     LOG_LEVEL_WARN (read-only)
#@const     LOG_LEVEL_WARN_COLOR (read-only)
#@const     LOG_COLOR_OFF (read-only)
#@arg       message: message to log
#@stdout    Writes the warning message to stdout
log_warn() {
    log__log "$LOG_LEVEL_WARN" "$1" "$LOG_LEVEL_WARN_COLOR" "$LOG_COLOR_OFF"
}


#@desc      Log an error message.
#@ex        log_error \"This is an error message\"
#@const     LOG_LEVEL_ERROR (read-only)
#@const     LOG_LEVEL_ERROR_COLOR (read-only)
#@const     LOG_COLOR_OFF (read-only)
#@arg       message: message to log
#@stdout    Writes the error message to stdout
log_error() {
    log__log "$LOG_LEVEL_ERROR" "$1" "$LOG_LEVEL_ERROR_COLOR" "$LOG_COLOR_OFF" >&2
}


#@desc      Log a fatal message.
#@ex        log_fatal \"This is a fatal message\"
#@const     LOG_LEVEL_FATAL (read-only)
#@const     LOG_LEVEL_FATAL_COLOR (read-only)
#@const     LOG_COLOR_OFF (read-only)
#@arg       message: message to log
#@stdout    Writes the fatal message to stdout
log_fatal() {
    log__log "$LOG_LEVEL_FATAL" "$1" "$LOG_LEVEL_FATAL_COLOR" "$LOG_COLOR_OFF" >&2
}


#@desc      Log a banner message.
#@ex        log_banner \"This is a banner message\"
#@const     LOG_LEVEL_INFO_COLOR (read-only)
#@const     LOG_COLOR_OFF (read-only)
#@arg       message: message to log
#@stdout    Writes the banner message to stdout
log_banner() {
    log__banner "$*" "$LOG_LEVEL_INFO_COLOR" "$LOG_COLOR_OFF"
}
