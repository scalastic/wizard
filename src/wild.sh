#!/usr/bin/env bash

set -euo pipefail

source lib/ext/getoptions.sh

VERSION="0.0.1"

parser_definition() {
  setup   REST help:usage -- "Usage: wild.sh [options]... [arguments]..." ''
  msg -- 'Options:'
  flag    PARAM_DOCKER    -d                -- "executes on docker images" 
  disp    :usage          -h --help
  disp    VERSION         --version
}

eval "$(getoptions parser_definition) exit 1"


#echo "PARAM_DOCKER: $PARAM_DOCKER, PARAM: $PARAM, OPTION: $OPTION"
#printf '%s\n' "$@" # rest arguments

export WID_CWD="${PWD}"

if [ -n "${PARAM_DOCKER}" ] && [  "${PARAM_DOCKER}" -eq "1" ]; then
    echo "Starting containers..."
    # Build images
    #"${WID_CWD}"/docker/build-all-images.sh
    # Start containers
    docker container run \
      --mount type=bind,source="$WID_CWD/config",target="/app/config"\
      -td --name basic-wild \
      scalastic/wild:latest \
      /bin/bash
fi

# shellcheck disable=SC1091
source lib/platform.sh
# shellcheck disable=SC1091
source lib/sequence.sh

load_sequence
