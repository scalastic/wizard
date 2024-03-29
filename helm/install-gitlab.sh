#!/usr/bin/env bash
#
# Installs GitLab from Helm chart with a wildcard self signed certificate for TLS with a self signed CA
#
# Usage:
#   ./install-gitlab.sh
#
# Requires:
#   - kubectl
#   - helm
#   - openssl
#
# References:
#   - https://docs.gitlab.com/charts/installation/
#   - https://docs.gitlab.com/charts/installation/advanced.html#install-gitlab-with-a-wildcard-self-signed-certificate-for-tls-with-a-self-signed-ca

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
  --set nginx-ingress.enabled=false \
  --set global.ingress.class="nginx" \
  --set certmanager.install=false \
  --set global.ingress.configureCertmanager=false \
  --set global.ingress.tls.secretName="${SERVER_NAME}-${COMPANY_NAME}-wildcard-tls" \
  --set postgresql.image.tag=13.6.0 \
  --set gitlab-runner.install=true \
  --set gitlab.webservice.minReplicas=1 --set gitlab.webservice.maxReplicas=1 \
  --set gitlab.sidekiq.minReplicas=1 --set gitlab.sidekiq.maxReplicas=1 \
  --set gitlab.gitlab-shell.minReplicas=1 --set gitlab.gitlab-shell.maxReplicas=1 \
  --set registry.hpa.minReplicas=1 --set registry.hpa.maxReplicas=1 \
  2>&1

kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode
echo
