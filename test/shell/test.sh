#!/usr/bin/env bash


SHELL_DIR=shell
LOG_DIR=tmp
LOG_LEVEL=0
LOGGER_COLORIZED=true

echo "${BASH_VERSION}"

. "${SHELL_DIR}/lib/core/runner.sh"
. "${SHELL_DIR}/lib/tls/core.sh"

rm -rf "${LOG_DIR}"

runner.run tls.create_server_cert jenkins scalastic "tmp/openssl"
ls -al tmp/openssl

runner.run tls.create_server_cert gitlab scalastic "tmp/openssl"
ls -al tmp/openssl

