#!/usr/bin/env bash
#@desc Installation script for GitLab-CI with Docker

set -euo pipefail

GITLAB_PATH="${PWD}/test/gitlab"
GITLAB_VOLUME_HOME="${GITLAB_PATH}/home"
GITLAB_INSTALLATION_CONFIG="${GITLAB_PATH}/config"

export GITLAB_HOME="${GITLAB_VOLUME_HOME}"

docker run --detach \
  --hostname gitlab.scalastic.local \
  --add-host=gitlab.scalastic.local:192.168.0.100 \
  --publish 127.0.0.1:4443:443 --publish 127.0.0.1:4080:80 --publish 127.0.0.1:4022:22 \
  --name gitlab \
  --restart always \
  --volume "${GITLAB_VOLUME_HOME}/config:/etc/gitlab" \
  --volume "${GITLAB_VOLUME_HOME}/logs:/var/log/gitlab" \
  --volume "${GITLAB_VOLUME_HOME}/data:/var/opt/gitlab" \
  --env GITLAB_ROOT_PASSWORD=p@ssw0rd \
  --shm-size 256m \
  gitlab/gitlab-ce:latest

#docker run \
#  --rm \
#  --name gitlab \
#  --hostname gitlab.example.com \
#  --publish 443:443 --publish 80:80 --publish 22:22 \
#  --volume "${GITLAB_VOLUME_HOME}/config:/etc/gitlab" \
#  --volume "${GITLAB_VOLUME_HOME}/logs:/var/log/gitlab" \
#  --volume "${GITLAB_VOLUME_HOME}/data:/var/opt/gitlab" \
#  --env GITLAB_ROOT_PASSWORD=p@ssw0rd \
#  --shm-size 256m \
#  gitlab/gitlab-ce:latest

docker logs -f gitlab

docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password