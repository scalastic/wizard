#!/usr/bin/env bash
#@desc Build scripts used in stage

set -euo pipefail
source ./src/lib/log.sh

log_info "Running bash --version..."
bash --version
