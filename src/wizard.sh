#!/usr/bin/env bash

set -euo pipefail

export WIZARD_CWD="${PWD}"
export LOG_PATH="${WIZARD_CWD}/tmp" && mkdir -p "${LOG_PATH}"
export CONFIG_PATH="./config"
# shellcheck disable=SC2034
VERSION="0.0.1"

# shellcheck disable=SC1091
source "${WIZARD_CWD}/src/lib/ext/getoptions.sh"

parser_definition() {
  setup REST help:usage -- "Usage: wizard.sh [options]... [arguments]..." ''
  msg -- 'Options:'
  flag PARAM_DOCKER -d -- "executes on docker images"
  disp :usage -h --help
  disp VERSION --version
}


eval "$(getoptions parser_definition) exit 1"

if [ -n "${PARAM_DOCKER}" ] && [ "${PARAM_DOCKER}" -eq "1" ]; then
  echo "Starting containers..."
  # Build images
  "${WIZARD_CWD}"/docker/build-all-images.sh
  # Start containers
  #docker container run \
  #  --mount type=bind,source="$WIZARD_CWD/config",target="/app/config"\
  #  -td --name basic-wizard \
  #  scalastic/wizard:latest \
  #  /bin/bash
fi

# Import librairies
# shellcheck disable=SC1091
source "${WIZARD_CWD}/src/lib/log.sh"
export LOG_LEVEL="$LOG_LEVEL_DEBUG"
# shellcheck disable=SC1091
source "${WIZARD_CWD}/src/lib/tooling.sh"
tooling::set_jq

# shellcheck disable=SC1091
source "${WIZARD_CWD}/src/lib/platform.sh"
# shellcheck disable=SC1091
source "${WIZARD_CWD}/src/lib/project.sh"
# shellcheck disable=SC1091
source "${WIZARD_CWD}/src/lib/workflow.sh"


#workflow_configuration_path=$(project::get_configuration_path)
#used_containers_names=$(workflow::_get_workflows_containers_names "$workflow_configuration_path")
