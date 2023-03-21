#!/usr/bin/env bash

set -euo pipefail

jq_from_file() {
    query=$1
    json=$2

    docker run \
    --mount type=bind,source="$WID_CWD/config",target="/app/config" \
    scalastic/wild:latest \
    bash -c "jq -rc '$query' $json"

}

jq_from_var() {
    query=$1
    json=$2

    docker run \
    --mount type=bind,source="$WID_CWD/config",target="/app/config" \
    scalastic/wild:latest \
    bash -c "echo '${json}' | jq -rc '$query'"

}