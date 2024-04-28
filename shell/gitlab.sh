#!/usr/bin/env bash

SHELL_DIR=shell
LOG_DIR=tmp
LOG_LEVEL=0
LOGGER_COLORIZED=true

# shellcheck source-path=shell
. "${SHELL_DIR}/lib/core/runner.sh"
. "${SHELL_DIR}/lib/gitlab/core.sh"

gitlab.start() {
    log.info "Starting GitLab..."
    gitlab.run gitlab
}

gitlab.configure_kubernetes_for_runner() {
    log.info "Configuring Kubernetes for runner..."
    gitlab.configure_kubernetes gitlab
}

gitlab.create_runner() {
    personal_access_token="${1}" # "glpat-iTAwRDu6fZxB3ZnXFgFm"

    log.info "Creating GitLab Runner..."

    local toml_config
    toml_config=$(curl --silent --request POST --url "http://gitlab.scalastic.local:4000/api/v4/user/runners" \
        --data "runner_type=instance_type" \
        --data "description=shared_runner" \
        --data "tag_list=all" \
        --header "PRIVATE-TOKEN: ${personal_access_token}"
    )

    log.info "Runner created: ${toml_config}"
}
