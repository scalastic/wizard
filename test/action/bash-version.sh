#!/usr/bin/env bash
#@desc Build scripts used in stage

set -euo pipefail

LOG_PATH="./log"
source ./src/lib/log.sh

log_info "Running bash --version..."
bash --version
