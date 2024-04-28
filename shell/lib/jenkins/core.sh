#!/usr/bin/env bash

# shellcheck source-path=shell
. "${SHELL_DIR}/lib/k8s/core.sh"
. "${SHELL_DIR}/lib/core/logger.sh"

jenkins.build_docker_images() {
    docker build \
    -t jenkins:jcasc \
    "infra/jenkins/config/"
}

jenkins.run_docker_container() {
    local name="${1}"

    local jenkins_home
    jenkins_home="$(pwd)/tmp/jenkins"

    mkdir -p "${jenkins_home}"

    docker run \
        --rm \
        --name "${name}" \
        --network wizard-network \
        --hostname jenkins.scalastic.local \
        -p 8080:8080 -p 50000:50000 \
        -v "${jenkins_home}:/var/jenkins_home" \
        --env "JENKINS_INSTALLATION_CONFIG=infra/jenkins/config" \
        --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password \
        jenkins:jcasc
}

jenkins.configure_kubernetes() {
    local name="${1}"

    k8s.create_namespace "${name}"
    k8s.create_service_account "${name}"
    k8s.create_service_account_secret "${name}"
    k8s.create_role_binding "${name}"
}

jenkins.configure_secrets() {
    local name="${1}"

    local service_account_token
    service_account_token="$(k8s.get_service_account_token "${name}")"

    sed "s/<SERVICE_ACCOUNT_TOKEN>/${service_account_token}/g" \
        "infra/jenkins/config/secrets-template.properties" > "infra/jenkins/config/secrets.properties"
    sed -i "s/<GITHUB_TOKEN>/${GITHUB_TOKEN}/g" "infra/jenkins/config/secrets.properties"
}

jenkins.install() {
    local name="${1:-jenkins}"

    jenkins.configure_kubernetes "${name}"
    jenkins.configure_secrets "${name}"
    jenkins.build_docker_images "${name}"
}

jenkins.run() {
    local name="${1:-jenkins}"

    jenkins.run_docker_container "${name}"
}