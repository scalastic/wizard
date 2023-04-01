#!/usr/bin/env bash

set -euo pipefail

INSTALL_NAMESPACE=jenkins

kubectl create namespace "$INSTALL_NAMESPACE"
kubectl config set-context --current --namespace="$INSTALL_NAMESPACE"

helm repo add jenkins https://charts.jenkins.io
helm repo update
helm upgrade --install jenkins jenkins/jenkins \
  --timeout 600s \
  --set 