#!/usr/bin/env bash

# shellcheck source-path=shell
. "${SHELL_DIR}/lib/core/logger.sh"
. "${SHELL_DIR}/lib/jenkins/core.sh"

jenkins.install_and_start() {
    log.info "Installing Jenkins..."
    jenkins.install jenkins

    log.info "Starting Jenkins..."
    jenkins.run jenkins
}

jenkins.start() {
    log.info "Starting Jenkins..."
    jenkins.run jenkins
}
