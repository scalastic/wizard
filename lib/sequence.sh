#!/usr/bin/env bash
#
# Sequence definition functions for bash scripts

set -euo pipefail

#######################################
# Check prerequisites for sequence.
# Globals:
#   JQ (read-only)
# Arguments:
#   None
# Outputs:
#   Writes the fatal message to stdout if prerequisites are not met and exit 255
#######################################
sequence::_check_prerequisites() {
    debug "Check prerequisites for sequence"

    local status=0

    if [ -z "${WILD_CWD:-}" ]; then
        error "Missing WILD_CWD environment variable"
        status=1
    fi
    
    if [ -z "${JQ:-}" ]; then
        error "Missing jq command"
        status=1
    fi

    if [ "$status" -ne 0 ]; then
        fatal "Prerequisites for sequence are not met"
        exit 255
    fi

    debug "WILD_CWD is ${WILD_CWD}"
    debug "jq command is ${JQ}"
}

#######################################
# Check if the sequence definition file exists.
# Globals:
#   None
# Arguments:
#   sequence_definition_path: path to the sequence definition file
# Outputs:
#   Writes the fatal message to stdout if the sequence definition file does not exist and exit 255
#   Writes the info message to stdout if the sequence definition file exists
#   Writes the sequence definition path to stdout
# Returns:
#   sequence_definition_path
#######################################
sequence::_check_sequence_definition_path() {
    local path

    debug "Check sequence definition path"

    if [ -z "${1:-}" ]; then
        info "No sequence definition path provided, using default one"
        path="config/sequence-default.json"
    else
        path="$1"
    fi

    if [ ! -f "${WILD_CWD}/${path}" ]; then
        fatal "Sequence definition file in ${path} does not exist"
        exit 255
    fi

    info "Load sequence definition from ${path}"
    echo "$path"
}

#######################################
# Load sequences id from a file.
# Globals:
#   JQ (read-only)
#   sequence_definition_path (read-only)
# Outputs:
#   Writes debug messages to stdout
# Returns:
#   sequences_id
#######################################
sequence::_load_sequences_id() {
    local sequence_definition_path="${1:-}"
    
    # shellcheck disable=SC2207
    local sequences_id=($("$JQ" < "${WILD_CWD}/${sequence_definition_path}" -rc '.sequence[].id'))

    # shellcheck disable=SC2145
    debug "Sequences id are ${sequences_id[@]}"
    debug "Sequences have ${#sequences_id[@]} ids"

    echo "${sequences_id[@]}"
}

#######################################
# Load sequence definition from a file.
# Globals:
#   JQ (read-only)
# Arguments:
#   sequence_definition_path: path to the sequence definition file
# Outputs:
#   Writes the sequence definition details to stdout
# Returns:
#   None
#######################################
sequence::load() {
    local sequence_definition_path="${1:-}"

    sequence_definition_path=$(sequence::_check_sequence_definition_path "$sequence_definition_path")
    sequence::_check_prerequisites

    local sequences_id
    sequences_id=$(sequence::_load_sequences_id "$sequence_definition_path")

    for item in "${sequences_id[@]}"; do
        warn "Step is $item"

        # shellcheck disable=SC2207 disable=SC2016
        local step_definition=($("$JQ" <"${sequence_definition_path}" -rc --arg item "$item" '.sequence[] | select(.id == $item)'))
        # shellcheck disable=SC2128
        info "Step definition is ${step_definition}"

        # shellcheck disable=SC2207 disable=SC2128
        local step_keys=($("$JQ" <<<"$step_definition" -rc 'keys_unsorted | @sh' | tr -d \'))
        # shellcheck disable=SC2145
        debug "Keys definition is ${step_keys[@]}"

        local initializer
        # shellcheck disable=SC2128 disable=SC2086
        initializer=$("$JQ" <<<$step_definition 'to_entries[] | "\(.key)=\(.value)"' | tr -d \")
        eval "$initializer"

        # Read env values defining step config
        for key in "${step_keys[@]}"; do
            info "$key = $(eval echo \$"$key")"
        done
    done

    if [ "$IS_DOCKERIZED_JQ" = "true" ]; then
        # Clean used and stopped containers
        # shellcheck disable=SC2046
        docker rm $(docker ps -a -q --filter "ancestor=scalastic/wild") >/dev/null
    fi
}
