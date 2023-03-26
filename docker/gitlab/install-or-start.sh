#!/usr/bin/env bash

set -euo pipefail

export WID_CWD="${PWD}"
export GITLAB_HOME="${WID_CWD}/run/gitlab"

mkdir -p "$GITLAB_HOME"

# When using Docker Destop for mac, make sur that "file sharing implementation" is not
# set to "VirtioFS" as it is buggy on rigths management when gitlab is installing.
sudo docker run --detach \
  --add-host=gitlab.example.com:192.168.0.10 \
  --publish 1443:443 --publish 1080:80 --publish 1022:22 \
  --name gitlab \
  --restart always \
  --volume "$GITLAB_HOME"/config:/etc/gitlab \
  --volume "$GITLAB_HOME"/logs:/var/log/gitlab \
  --volume "$GITLAB_HOME"/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ce:15.10.0-ce.0

while [ ! -f "$GITLAB_HOME/config/initial_root_password" ]
do
  sleep 2
done

echo "****** Initial Root password is ******"
cat "$GITLAB_HOME/config/initial_root_password"
