#!/usr/bin/env bash

set -euo pipefail

COMPANY_NAME=scalastic
NAMESPACE=monitoring
SERVER_NAME=prometheus
CA_PATH=openssl/ca
CERT_PATH="openssl"

# Create dedicated namespace if not exist and default to it
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace="$NAMESPACE"

# Create dedicated wildcard certificate
#echo "Generating certificates..."
#[ ! -f "${CA_PATH}/${COMPANY_NAME}-ca-tls.key" ] && ./helm/create-ca-tls.sh "${COMPANY_NAME}"
#./helm/create-cert-server.sh "${SERVER_NAME}"

#echo "Creating secret tls..."

#set +e
#kubectl get secret "${SERVER_NAME}-${COMPANY_NAME}-wildcard-tls" 2>/dev/null
#secretExists="$?"
#set -e

#if [ "$secretExists" -eq "0" ]; then
#  kubectl -n "$NAMESPACE" delete secret "${SERVER_NAME}-${COMPANY_NAME}-wildcard-tls"
#fi

#kubectl -n "$NAMESPACE" create secret tls "${SERVER_NAME}-${COMPANY_NAME}-wildcard-tls" \
#  --cert="./${CERT_PATH}/${SERVER_NAME}-wildcard-tls.crt" \
#  --key="./${CERT_PATH}/${SERVER_NAME}-wildcard-tls.key"

# Install Prometheus
echo "Installing Prometheus Stack..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  2>&1

kubectl patch ds prometheus-prometheus-node-exporter \
  -n monitoring \
  --type "json" -p '[{"op": "remove", "path" : "/spec/template/spec/containers/0/volumeMounts/2/mountPropagation"}]'
