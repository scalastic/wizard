#!/usr/bin/env bash

# shellcheck source-path=shell
. "${SHELL_DIR}/lib/k8s/core.sh"
. "${SHELL_DIR}/lib/core/logger.sh"


gitlab.run_docker_container() {
    local name="${1}"

    local gitlab_home
    gitlab_home="$(pwd)/tmp/gitlab"

    mkdir -p "${gitlab_home}"

    docker run --detach \
        --platform linux/amd64 \
        --name "${name}" \
        --network wizard-network \
        --hostname "${name}".scalastic.local \
        --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.scalastic.local'" \
        --env GITLAB_INSTALLATION_CONFIG="infra/gitlab/config" \
        --publish 443:443 --publish 4000:80 --publish 22:22 \
        --volume "${gitlab_home}/config:/etc/gitlab" \
        --volume "${gitlab_home}/logs:/var/log/gitlab" \
        --volume "${gitlab_home}/data:/var/opt/gitlab" \
        --env GITLAB_ROOT_PASSWORD=p@ssw0rd \
        --env GITLAB_HOME="${gitlab_home}" \
        --shm-size 256m \
        gitlab/gitlab-ce:latest

    #   --env GITLAB_INSTALLATION_CONFIG="infra/gitlab/config" \
}

gitlab.create_runner_secret() {
    local name="${1}"

    kubectl create secret generic "${name}-runner-secret" \
        --namespace "${name}" \
        --from-literal=runner-registration-token="" \
        --from-literal=runner-token="REDACTED"
}


gitlab.configure_kubernetes() {
    local name="${1}"

    k8s.create_namespace "${name}"
    k8s.create_service_account "${name}"
    k8s.create_service_account_secret "${name}"
    k8s.create_role_binding "${name}"
}

gitlab.configure_helm() {
    local name="${1}"

    gitlab.create_runner_secret "${name}"

    helm repo add gitlab https://charts.gitlab.io
    helm repo update gitlab

    helm install --namespace "${name}" "${name}-runner" -f infra/gitlab/config/runner.yaml gitlab/gitlab-runner
}

gitlab.install() {
    local name="${1:-gitlab}"

    gitlab.configure_kubernetes "${name}"
    gitlab.configure_helm "${name}"
}

gitlab.run() {
    local name="${1:-gitlab}"

    gitlab.run_docker_container "${name}"
}