#!/usr/bin/env bash

SHELL_DIR=shell
LOG_DIR=tmp
LOG_LEVEL=0
LOGGER_COLORIZED=true

# shellcheck source-path=shell
. "${SHELL_DIR}/lib/core/runner.sh"
. "${SHELL_DIR}/lib/gitlab/core.sh"

gitlab.install_and_start() {
    log.info "Installing GitLab..."
    gitlab.install gitlab

    log.info "Starting GitLab..."
    gitlab.run gitlab
}

gitlab.start() {
    log.info "Starting GitLab..."
    gitlab.run gitlab
}

#runner.run gitlab.install_and_start