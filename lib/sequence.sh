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
    #SEQUENCES_ID=( $(jq -rc '.sequence[].id' "${DEFAULT_SEQUENCE_DEFINITION_PATH}") )
    SEQUENCES_ID=( $(docker run -i scalastic/wild:latest < "${DEFAULT_SEQUENCE_DEFINITION_PATH}" -rc '.sequence[].id') )

    # shellcheck disable=SC2145
    echo "SEQUENCES is ${SEQUENCES_ID[@]}"
    echo "SEQUENCES have ${#SEQUENCES_ID[@]} elements"

    # For each item in sequence
    #  - Load configuration of step
    #  - Execute step
    for item in "${SEQUENCES_ID[@]}"; do
        echo "STEP is $item"

        echo "Load step definition from ${DEFAULT_SEQUENCE_DEFINITION_PATH}"
        # shellcheck disable=SC2207
        STEP_DEFINITION=$(docker run -i scalastic/wild:latest < "${DEFAULT_SEQUENCE_DEFINITION_PATH}" -rc --arg item "$item" '.sequence[] | select(.id == $item)')
        echo "Step definition is ${STEP_DEFINITION}"

        # shellcheck disable=SC2207
        STEP_KEYS=( $(docker run -i scalastic/wild:latest <<< "$STEP_DEFINITION" -rc 'keys_unsorted | @sh' | tr -d \') )
        # shellcheck disable=SC2145
        echo "Keys definition is ${STEP_KEYS[@]}"

        # shellcheck disable=SC2091 disable=SC2086
        initializer=$(docker run -i scalastic/wild:latest <<< $STEP_DEFINITION 'to_entries[] | "\(.key)=\(.value)"' | tr -d \")
        eval "$initializer"

        # Read env values defining step config
        for key in "${STEP_KEYS[@]}"; do
            echo -n "$key = "
            eval echo \$"$key"
        done
    done

    # Clean used and stopped containers
    # shellcheck disable=SC2046
    docker rm $(docker ps -a -q --filter "ancestor=scalastic/wild") > /dev/null

}