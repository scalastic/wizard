#!/usr/bin/env bash
#@desc Sequence definition functions for bash scripts

set -euo pipefail


#@desc      Check prerequisites for sequence.
#@ex        sequence::_check_prerequisites
#@const     JQ (read-only)
#@return    255 if the prerequisites are not met
sequence::_check_prerequisites() {
    log::debug "Check prerequisites for sequence"

    local status=0

    if [ -z "${WILD_CWD:-}" ]; then
        log::error "Missing WILD_CWD environment variable"
        status=1
    fi

    if [ -z "${JQ:-}" ]; then
        log::error "Missing jq command"
        status=1
    fi

    if [ "$status" -ne 0 ]; then
        log::fatal "Prerequisites for sequence are not met"
        exit 255
    fi

    log::debug "WILD_CWD is ${WILD_CWD}"
    log::debug "jq command is ${JQ}"
}


#@desc      Check if the sequence definition file exists.
#@ex        sequence::_check_sequence_definition_path
#@arg       sequence_definition_path: path to the sequence definition file
#@stderr    Writes the fatal message to stdout if the sequence definition file does not exist and exit 255
#@stdout    Writes the info message to stdout if the sequence definition file exists
#@return    sequence_definition_path: path to the sequence definition file
sequence::_check_sequence_definition_path() {
    local path

    log::debug "Check sequence definition path"

    if [ -z "${1:-}" ]; then
        log::info "No sequence definition path provided, using default one"
        path="config/sequence-default.json"
    else
        path="$1"
    fi

    if [ ! -f "${WILD_CWD}/${path}" ]; then
        log::fatal "Sequence definition file in ${path} does not exist"
        exit 255
    fi

    log::info "Load sequence definition from ${path}"
    echo "$path"
}


#@desc      Load sequences id from a file.
#@ex        sequence::_load_sequences_id \"config/sequence-default.json\"
#@const     JQ (read-only)
#@const     sequence_definition_path (read-only)
#@stdout    Writes debug messages to stdout
#@return    id of the sequences as array
sequence::_load_sequences_id() {
    local sequence_definition_path="${1:-}"

    # shellcheck disable=SC2207
    local sequences_id=($("$JQ" <"${WILD_CWD}/${sequence_definition_path}" -rc '.sequence[].id'))

    # shellcheck disable=SC2145
    log::debug "Sequences id are: ${sequences_id[@]}"
    log::debug "Sequences have ${#sequences_id[@]} ids"

    echo "${sequences_id[@]}"
}


#@desc      Load step definition from an item and the sequence definition file.
#@ex        sequence::_load_step_definition \"step1\" \"config/sequence-default.json\"
#@const     JQ (read-only)
#@const     sequence_definition_path (read-only)
#@arg       item_id: id of the item to load
#@arg       sequence_definition_path: path to the sequence definition file
#@stdout    Writes debug messages to stdout
#@return    Step definition as array
sequence::_load_step_definition() {
    local item_id="${1:-}"
    local sequence_definition_path="${2:-}"

    local step_definition
    # shellcheck disable=SC2207
    step_definition=($("$JQ" <"${WILD_CWD}/${sequence_definition_path}" -rc ".sequence[] | select(.id == \"${item_id}\")"))

    # shellcheck disable=SC2145
    log::debug "Step definition is: ${step_definition[@]}"

    echo "${step_definition[@]}"
}


#@desc      Load step values as environment variables from a step definition as JSON.
#@ex        sequence::_load_step_values \"[\"id\":\"step1\",\"name\":\"Step 1\",\"description\":\"Step 1 description\",\"type\":\"command\",\"command\":\"echo 'Step 1'\"]\"
#@const     JQ (read-only)
#@arg       step_definition: step definition to load
#@stdout    Writes debug messages to stdout
#@return    The step values
sequence::_load_step_values() {

    local step_definition=("${1}")
    local initializer
    # shellcheck disable=SC2128 disable=SC2086
    initializer=$("$JQ" <<<$step_definition 'to_entries[] | "\(.key)=\(.value)"' | tr -d \")

    log::debug "Step values are: $initializer"

    eval "$initializer"
}


#@desc      Iterate over sequence.
#@ex        sequence::_iterate_over_sequence \"config/sequence-default.json\" \"step1 step2 step3\"
#@const     sequence_definition_path (read-only)
#@arg       sequence_definition_path: path to the sequence definition file
#@arg       sequences_id: array of sequences id
sequence::_iterate_over_sequence() {
    local sequence_definition_path="${1}"
    shift
    local sequences_id=("$@")

    for item in "${sequences_id[@]}"; do
        log::info "Loop over step $item"

        local step_definition
        # shellcheck disable=SC2207
        step_definition=($(sequence::_load_step_definition "$item" "$sequence_definition_path"))

        # shellcheck disable=SC2128 disable=SC2145
        log::debug "Step definition is ${step_definition[@]}"

        sequence::_load_step_values "${step_definition[@]}"
    done

}


#@desc      Load sequence definition from a file.
#@ex        sequence::load \"config/sequence-default.json\"
#@const     JQ (read-only)
#@arg       sequence_definition_path: path to the sequence definition file
#@stdout    Writes the sequence definition details to stdout
# shellcheck disable=SC2120
sequence::load() {
    local sequence_definition_path="${1:-}"

    sequence_definition_path=$(sequence::_check_sequence_definition_path "$sequence_definition_path")
    sequence::_check_prerequisites

    local sequences_id=()
    # shellcheck disable=SC2207
    sequences_id+=($(sequence::_load_sequences_id "$sequence_definition_path"))

    # shellcheck disable=SC2145
    log::debug "Caller Sequences id are: ${sequences_id[@]}"
    log::debug "Length Sequences id are: ${#sequences_id[@]}"

    sequence::_iterate_over_sequence "$sequence_definition_path" "${sequences_id[@]}"

    if [ "$IS_DOCKERIZED_JQ" = "true" ]; then
        # Clean used and stopped containers
        # shellcheck disable=SC2046
        docker rm $(docker ps -a -q --filter "ancestor=scalastic/wild") >/dev/null
    fi
}
