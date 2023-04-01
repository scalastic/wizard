#!/usr/bin/env bash

set -euo pipefail

export WID_CWD="${PWD}"
export GITLAB_RUNNER_HOME="${WID_CWD}/run/gitlab-runner"
export REGISTRATION_TOKEN="GR1348941JBZYBkw5-XQEQMkeSh33"

sudo docker run --detach \
    --add-host=gitlab.scalastic.io:192.168.0.10 \
    --name gitlab-runner \
    --restart always \
    --volume "$GITLAB_RUNNER_HOME"/config:/etc/gitlab-runner \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    gitlab/gitlab-runner:ubuntu-v15.9.1

sudo docker exec -it gitlab-runner gitlab-runner register \
    --url "http://gitlab.scalastic.io:1080/" \
    --registration-token "$REGISTRATION_TOKEN" \
    --executor "docker" \
    --description "maven:3.8-openjdk-18-slim Runner" \
    --docker-image "maven:3.8-openjdk-18-slim" \
    --docker-volumes /var/run/docker.sock:/var/run/docker.sock
