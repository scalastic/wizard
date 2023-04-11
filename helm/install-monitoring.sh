#!/usr/bin/env bash
#
# Installs Prometheus Stack from Helm chart
#
# Usage:
#   ./install-monitoring.sh
#
# Requires:
#   - kubectl
#   - helm
#
# References:
#   - https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack


set -euo pipefail

NAMESPACE=monitoring

# Create dedicated namespace if not exist and default to it
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace="$NAMESPACE"

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
