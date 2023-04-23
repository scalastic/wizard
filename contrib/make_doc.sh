#!/usr/bin/env bash
#
# Generates Wild source code documentation.

set -euo pipefail

rm -rf docs/lib
mkdir -p docs/lib

# shellcheck disable=SC2046 disable=SC2038
./lib/ext/gendoc.sh $(find lib -path lib/ext -prune -o -name '*.sh' -print | xargs echo)

echo "ok"