#!/usr/bin/env bash

set -euo pipefail

jq_query() {
    query=$1
    json=$2

    docker run \
    --mount type=bind,source="$WID_CWD/config",target="/root/config" \
    wid/basic:latest \
    bash -c "jq -r '$query' $json"

}