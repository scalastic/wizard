#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source shell/lib/jq.sh

sequence.load() {

    DEFAULT_SEQUENCE_DEFINITION_PATH=${1:-./config/default/sequence-default.json}
    echo "Loading sequence definition from ${DEFAULT_SEQUENCE_DEFINITION_PATH}"

    # shellcheck disable=SC2207
    SEQUENCES_ID=( $(jq_query '.sequence[].id' "${DEFAULT_SEQUENCE_DEFINITION_PATH}") )

    # shellcheck disable=SC2145
    echo "SEQUENCES is ${SEQUENCES_ID[@]}"
    echo "SEQUENCES have ${#SEQUENCES_ID[@]} elements"

    # For each item in sequence
    #  - Load configuration of step
    #  - Execute step
    for item in "${SEQUENCES_ID[@]}"; do
        echo "$item"

        STEP_DEFINITION_PATH=$(get_step_definition "$item")

        echo "Load step definition from ${STEP_DEFINITION_PATH}"

        # shellcheck disable=SC2140
        STEP_DEFINITION="$(docker run \
        --mount type=bind,source="$WID_CWD/config",target="/root/config" \
        wid/basic:latest \
        bash -c "jq -r '.step | arrays | @tsv' ${STEP_DEFINITION_PATH}")"

        read -r -a STEP <<< "$STEP_DEFINITION"

        # shellcheck disable=SC2145
        echo "Step definition is ${STEP[@]}"
    done

}