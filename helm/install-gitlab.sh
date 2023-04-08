#!/usr/bin/env bash

set -euo pipefail

COMPANY_NAME=scalastic
NAMESPACE=gitlab
SERVER_NAME=gitlab
CA_PATH=openssl/ca
CERT_PATH="openssl"

# Create dedicated namespace if not exist and default to it
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace="$NAMESPACE"

# Create dedicated wildcard certificate
echo "Generating certificates..."
[ ! -f "${CA_PATH}/${COMPANY_NAME}-ca-tls.key" ] && ./helm/create-ca-tls.sh "${COMPANY_NAME}"
./helm/create-wildcard-cert-server.sh "${SERVER_NAME}"

echo "Creating secret tls..."

set +e
kubectl get secret "${SERVER_NAME}-${COMPANY_NAME}-wildcard-tls" 2>/dev/null
secretExists="$?"
set -e

if [ "$secretExists" -eq "0" ]; then
  kubectl -n "$NAMESPACE" delete secret "${SERVER_NAME}-${COMPANY_NAME}-wildcard-tls"
fi

kubectl -n "$NAMESPACE" create secret tls "${SERVER_NAME}-${COMPANY_NAME}-wildcard-tls" \
  --cert="./${CERT_PATH}/${SERVER_NAME}-wildcard-tls.crt" \
  --key="./${CERT_PATH}/${SERVER_NAME}-wildcard-tls.key"

# Install GitLab
echo "Installing GitLab..."
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm -n "$NAMESPACE" upgrade --install --create-namespace gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.edition=ce \
  --set global.hosts.domain=scalastic.local \
  --set global.hosts.externalIP=192.168.0.10 \
  --set postgresql.image.tag=13.6.0 \
  --set certmanager.install=false \
  --set global.ingress.configureCertmanager=false \
  --set global.ingress.tls.secretName="${SERVER_NAME}-${COMPANY_NAME}-wildcard-tls" \
  --set gitlab-runner.install=true \
  2>&1

kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
