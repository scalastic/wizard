#!/usr/bin/env bash
#
# Inline Wild script and act as a wrapper.
# This script is for release purposes.

set -euo pipefail

export WILD_CWD="${PWD}"

mkdir -p ./bin
rm -f ./bin/wizard
./src/lib/ext/inline.sh --in-file ./src/wizard.sh --out-file ./bin/wizard
grep -Ev "^[[:blank:]]*#[^!]|^[[:blank:]]*$" ./bin/wild > ./bin/wild.tmp
mv ./bin/wild.tmp ./bin/wild
chmod u+x ./bin/wild

echo "ok"
