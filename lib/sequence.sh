#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source lib/jq.sh
# shellcheck disable=SC1091
source lib/step.sh

load_sequence() {

    DEFAULT_SEQUENCE_DEFINITION_PATH=${1:-"config/default/sequence-default.json"}
    echo "Loading sequence definition from ${DEFAULT_SEQUENCE_DEFINITION_PATH}"

    # shellcheck disable=SC2207
    SEQUENCES_ID=( $(jq -rc '.sequence[].id' "${DEFAULT_SEQUENCE_DEFINITION_PATH}") )

    # shellcheck disable=SC2145
    echo "SEQUENCES is ${SEQUENCES_ID[@]}"
    echo "SEQUENCES have ${#SEQUENCES_ID[@]} elements"

    # For each item in sequence
    #  - Load configuration of step
    #  - Execute step
    for item in "${SEQUENCES_ID[@]}"; do
        echo "STEP is $item"

        #STEP_DEFINITION_PATH=$(get_step_definition "$item")

        echo "Load step definition from ${DEFAULT_SEQUENCE_DEFINITION_PATH}"

        # shellcheck disable=SC2207
        STEP_DEFINITION=$(jq -rc --arg item "$item" '.sequence[] | select(.id == $item)' "${DEFAULT_SEQUENCE_DEFINITION_PATH}")
        # shellcheck disable=SC2145
        echo "Step definition is ${STEP_DEFINITION}"

        # shellcheck disable=SC2207 disable=SC2086
        STEP_KEYS=( $( jq -rc 'keys_unsorted | @sh' <<< ${STEP_DEFINITION} | tr -d \') )
        # shellcheck disable=SC2145
        echo "Keys definition is ${STEP_KEYS[@]}"

        # shellcheck disable=SC2091 disable=SC2086
        initializer=$(jq 'to_entries[] | "\(.key)=\(.value)"' <<< $STEP_DEFINITION | tr -d \")
        eval "$initializer"

        for key in "${STEP_KEYS[@]}"; do
            echo -n "$key = "
            eval echo \$"$key"
        done
    done

}