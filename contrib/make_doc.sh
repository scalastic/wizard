#!/usr/bin/env bash
#
# Generate documentation for source for Wild.

set -euo pipefail

export WILD_CWD="${PWD}"

# shellcheck disable=SC2046 disable=SC2038
./lib/ext/doc.sh $(find lib -path lib/ext -prune -o -name '*.sh' -print | xargs echo)

echo "ok"