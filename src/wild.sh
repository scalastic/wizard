#!/usr/bin/env bash

set -euo pipefail

export WILD_CWD="${PWD}"
VERSION="0.0.1"

# shellcheck disable=SC1091
source "${WILD_CWD}/lib/ext/getoptions.sh"

parser_definition() {
  setup REST help:usage     -- "Usage: wild.sh [options]... [arguments]..." ''
  msg                       -- 'Options:'
  flag PARAM_DOCKER     -d  -- "executes on docker images"
  disp :usage           -h  --help
  disp VERSION              --version
}

eval "$(getoptions parser_definition) exit 1"

if [ -n "${PARAM_DOCKER}" ] && [ "${PARAM_DOCKER}" -eq "1" ]; then
  echo "Starting containers..."
  # Build images
  "${WILD_CWD}"/docker/build-all-images.sh
  # Start containers
  #docker container run \
  #  --mount type=bind,source="$WILD_CWD/config",target="/app/config"\
  #  -td --name basic-wild \
  #  scalastic/wild:latest \
  #  /bin/bash
fi

# Import librairies
# shellcheck disable=SC1091
source lib/log.sh
# shellcheck disable=SC1091
source lib/tooling.sh
set_jq_tool

# shellcheck disable=SC1091
source lib/platform.sh
# shellcheck disable=SC1091
source lib/sequence.sh

sequence::load
