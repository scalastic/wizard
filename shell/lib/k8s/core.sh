#!/usr/bin/env bash

# shellcheck source-path=shell
. "${SHELL_DIR}/lib/core/logger.sh"

k8s.create_namespace() {
    local name="${1}"

    kubectl delete namespace "${name}" || true
    kubectl create namespace "${name}"
}

k8s.create_service_account() {
    local name="${1}"

    kubectl create serviceaccount "${name}-serviceaccount" \
    --namespace="${name}"
}

k8s.get_service_account_token() {
    local name="${1}"

    kubectl get "secrets/${name}-secret" \
        --namespace="${name}" \
        -ojsonpath='{.data.token}' \
        | base64 --decode
}


k8s.create_role_binding() {
    local name="${1}"

    kubectl create rolebinding "${name}"-admin-binding \
        --clusterrole=admin \
        --serviceaccount="${name}":"${name}-serviceaccount" \
        --namespace="${name}"
}

k8s.create_service_account_secret() {
    local name="${1}"

    kubectl apply --namespace="${name}" -f - <<EOF
        apiVersion: v1
        kind: Secret
        metadata:
            name: "${name}-secret"
            annotations:
                kubernetes.io/service-account.name: "${name}-serviceaccount"
        type: kubernetes.io/service-account-token
EOF
}