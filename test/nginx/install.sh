#!/usr/bin/env bash
#@desc Installation script for Jenkins with Docker

set -euo pipefail

source .env
export LOG_PATH="./log"
source ./src/lib/common.sh

NGINX_PATH="${PWD}/test/nginx"
NGINX_INSTALLATION_CONFIG="${NGINX_PATH}/config"
NGINX_VOLUME_HOME="${NGINX_PATH}/home"
DOCKER_NETWORK="wizard-network"
LOCAL_IP_ADDRESS=$(tooling_get_ip)

# shellcheck disable=SC2143
if [ ! "$(docker network ls | grep ${DOCKER_NETWORK})" ]; then
  log_info "Creating ${DOCKER_NETWORK} network ..."
  docker network create "${DOCKER_NETWORK}"
  docker network connect "${DOCKER_NETWORK}" jenkins
else
  log_info "${DOCKER_NETWORK} network already exists."
fi

# shellcheck disable=SC2143
if [ ! "$(docker ps | grep ${DOCKER_NETWORK})" ]; then
    if [ "$(docker ps -aq -f name=nginx)" ]; then
        # cleanup
        log_info "Cleaning nginx Proxy ..."
        docker rm nginx
    fi
    # build your container
    docker build \
      -t nginx:test \
      "${NGINX_INSTALLATION_CONFIG}"
    # run your container in our global network shared by different projects
    log_info "Running nginx Proxy in global ${DOCKER_NETWORK} network ..."
    docker run \
      --detach \
      --name nginx \
       -p 80:80 \
       -p 443:443 \
       --network="${DOCKER_NETWORK}" \
       nginx:test
else
  log_info "nginx Proxy already running."
fi
