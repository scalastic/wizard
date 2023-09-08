#!/usr/bin/env bash

set -euo pipefail

export WILD_CWD="${PWD}"
export LOG_PATH="${WILD_CWD}/tmp" && mkdir -p "${LOG_PATH}"
export CONFIG_PATH="./config"
# shellcheck disable=SC2034
VERSION="0.0.1"

# shellcheck disable=SC1091
source "${WILD_CWD}/src/lib/ext/getoptions.sh"

parser_definition() {
  setup REST help:usage -- "Usage: wild.sh [options]... [arguments]..." ''
  msg -- 'Options:'
  flag PARAM_DOCKER -d -- "executes on docker images"
  disp :usage -h --help
  disp VERSION --version
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
source "${WILD_CWD}/src/lib/log.sh"
export LOG_LEVEL="$LOG_LEVEL_DEBUG"
# shellcheck disable=SC1091
source "${WILD_CWD}/src/lib/tooling.sh"
tooling::set_jq

# shellcheck disable=SC1091
source "${WILD_CWD}/src/lib/platform.sh"
# shellcheck disable=SC1091
source "${WILD_CWD}/src/lib/project.sh"
# shellcheck disable=SC1091
source "${WILD_CWD}/src/lib/workflow.sh"


workflow_configuration_path=$(project::get_configuration_path)
# shellcheck disable=SC2034
used_containers_names=$(workflow::_get_workflows_containers_names "$workflow_configuration_path")
