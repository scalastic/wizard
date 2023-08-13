#!/usr/bin/env bash
#@desc Installation script for Jenkins to use Kubernetes

set -euo pipefail

kubectl create namespace jenkins
kubectl create serviceaccount jenkins --namespace=jenkins
kubectl create token jenkins --namespace=jenkins

TOKEN=$(kubectl create token jenkins --namespace=jenkins)
kubectl create rolebinding jenkins-admin-binding --clusterrole=admin --serviceaccount=jenkins:jenkins --namespace=jenkins