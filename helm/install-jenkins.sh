#!/usr/bin/env bash

set -euo pipefail

COMPANY_NAME=scalastic
NAMESPACE=jenkins
SERVER_NAME=jenkins
CA_PATH=openssl/ca
CERT_PATH="openssl"

# Create dedicated namespace if not exist and default to it
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace="$NAMESPACE"

# Create dedicated certificate
echo "Generating certificates..."
[ ! -f "${CA_PATH}/${COMPANY_NAME}-ca-tls.key" ] && ./helm/create-ca-tls.sh "${COMPANY_NAME}"
./helm/create-cert-server.sh "${SERVER_NAME}"

echo "Creating secret tls..."

set +e
kubectl get secret "${SERVER_NAME}-${COMPANY_NAME}-tls" 2>/dev/null
secretExists="$?"
set -e

if [ "$secretExists" -eq "0" ]; then
  kubectl -n "$NAMESPACE" delete secret "${SERVER_NAME}-${COMPANY_NAME}-tls"
fi

kubectl -n "$NAMESPACE" create secret tls "${SERVER_NAME}-${COMPANY_NAME}-tls" \
  --cert="./${CERT_PATH}/${SERVER_NAME}-tls.crt" \
  --key="./${CERT_PATH}/${SERVER_NAME}-tls.key"

# Install Ingress Nginx controller
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.admissionWebhooks.enabled=false


# Install Jenkins
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm upgrade --install jenkins --namespace jenkins \
    -f helm/jenkins/values.yaml \
    jenkinsci/jenkins 2>&1

#kubectl apply -f helm/jenkins/ingress.yaml >&1
