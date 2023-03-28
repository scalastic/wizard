#!/usr/bin/env bash

set -euo pipefail

helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.edition=ce \
  --set global.hosts.domain=scalastic.io \
  --set global.hosts.externalIP=192.168.0.10 \
  --set postgresql.image.tag=13.6.0 \
  --set certmanager.install=false \
  --set global.ingress.configureCertmanager=false \
  --set gitlab-runner.install=false

kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
