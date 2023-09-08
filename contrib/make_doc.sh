#!/usr/bin/env bash
#
# Generates Wizard source code documentation.

set -euo pipefail

rm -rf docs/src
mkdir -p docs/src

export LOG_PATH="./log"
export LOG_LEVEL="1"

# shellcheck disable=SC2046 disable=SC2038
./src/lib/ext/gendoc.sh $(find src/lib -path src/lib/ext -prune -o -name '*.sh' -print | xargs echo)

echo "ok"