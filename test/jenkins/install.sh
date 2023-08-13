#!/usr/bin/env bash
#@desc Installation script for Jenkins with Docker

set -euo pipefail

install::_configure_kubernetes() {
  declare -r name="jenkins"

  kubectl delete namespace "${name}"

  kubectl create namespace "${name}"
  kubectl create serviceaccount "${name}" --namespace="${name}"
  kubectl create token "${name}" --namespace="${name}"
  kubectl create rolebinding "${name}"-admin-binding --clusterrole=admin --serviceaccount="${name}":"${name}" --namespace="${name}"

  local TOKEN=$(kubectl create token "${name}" --namespace="${name}")
  sed "s/<SERVICE_ACCOUNT_TOKEN>/${TOKEN}/g" "${JENKINS_INSTALLATION_CONFIG}/secrets-template.properties" > "${JENKINS_INSTALLATION_CONFIG}/secrets.properties"
}

JENKINS_PATH="${PWD}/test/jenkins"
JENKINS_INSTALLATION_CONFIG="${JENKINS_PATH}/config"
JENKINS_VOLUME_HOME="${JENKINS_PATH}/home"

install::_configure_kubernetes

docker build \
  -t jenkins:jcasc \
  "${JENKINS_INSTALLATION_CONFIG}"

docker run \
  --rm \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v "${JENKINS_VOLUME_HOME}:/var/jenkins_home" \
  --env "JENKINS_INSTALLATION_CONFIG=${JENKINS_INSTALLATION_CONFIG}" \
  --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password \
  jenkins:jcasc
