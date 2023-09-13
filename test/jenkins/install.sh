#!/usr/bin/env bash
#@desc Installation script for Jenkins with Docker

set -euo pipefail

source .env
export LOG_PATH="./log"
source ./src/lib/common.sh

install__configure_kubernetes() {
  declare -r name="jenkins"

  kubectl delete namespace "${name}" || true

  kubectl create namespace "${name}"
  kubectl create serviceaccount "${name}-serviceaccount" --namespace="${name}"

  # Short-lived Token
  #kubectl create token "${name}" --namespace="${name}"
  #kubectl create rolebinding "${name}"-admin-binding --clusterrole=admin --serviceaccount="${name}":"${name}" --namespace="${name}"
  #local TOKEN
  #TOKEN=$(kubectl create token "${name}" --namespace="${name}")

  # Long-lived Token
  kubectl apply --namespace="${name}" -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: "${name}-secret"
  annotations:
    kubernetes.io/service-account.name: "${name}-serviceaccount"
type: kubernetes.io/service-account-token
EOF

  kubectl create rolebinding "${name}"-admin-binding --clusterrole=admin --serviceaccount="${name}":"${name}-serviceaccount" --namespace="${name}"

  local SERVICE_ACCOUNT_TOKEN
  SERVICE_ACCOUNT_TOKEN=$(kubectl get "secrets/${name}-secret" --namespace="${name}" -ojsonpath='{.data.token}' | base64 --decode)
  sed "s/<SERVICE_ACCOUNT_TOKEN>/${SERVICE_ACCOUNT_TOKEN}/g" "${JENKINS_INSTALLATION_CONFIG}/secrets-template.properties" > "${JENKINS_INSTALLATION_CONFIG}/secrets.properties"
  sed -i "s/<GITHUB_TOKEN>/${GITHUB_TOKEN}/g" "${JENKINS_INSTALLATION_CONFIG}/secrets.properties"
}

JENKINS_PATH="${PWD}/test/jenkins"
JENKINS_INSTALLATION_CONFIG="${JENKINS_PATH}/config"
JENKINS_VOLUME_HOME="${JENKINS_PATH}/home"
LOCAL_IP_ADDRESS=$(tooling_get_ip)

log_info "Local IP address is: ${LOCAL_IP_ADDRESS}"

install__configure_kubernetes

docker build \
  -t jenkins:jcasc \
  "${JENKINS_INSTALLATION_CONFIG}"

docker run \
  --rm \
  --name jenkins \
  --hostname jenkins.scalastic.local \
  -p 8080:8080 -p 50000:50000 \
  -v "${JENKINS_VOLUME_HOME}:/var/jenkins_home" \
  --env "JENKINS_INSTALLATION_CONFIG=${JENKINS_INSTALLATION_CONFIG}" \
  --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password \
  jenkins:jcasc
  # --env "LOCAL_IP_ADDRESS=${LOCAL_IP_ADDRESS}" \
  # --add-host=jenkins.scalastic.local:"${LOCAL_IP_ADDRESS}" \
