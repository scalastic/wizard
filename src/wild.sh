#!/usr/bin/env bash

set -euo pipefail

export WID_CWD="${PWD}"

# shellcheck disable=SC1091
source lib/platform.sh
source lib/sequence.sh

# TO EXTRACT
#"${WID_CWD}"/docker/build-all-images.sh

load_sequence
