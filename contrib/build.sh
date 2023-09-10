#!/usr/bin/env bash
#
# Inline Wizard script and act as a wrapper.
# This script is for release purposes.

set -euo pipefail

export WIZARD_CWD="${PWD}"

mkdir -p ./bin
rm -f ./bin/wizard
./src/lib/ext/inline.sh --in-file ./src/wizard.sh --out-file ./bin/wizard
grep -Ev "^[[:blank:]]*#[^!]|^[[:blank:]]*$" ./bin/wizard > ./bin/wizard.tmp
mv ./bin/wizard.tmp ./bin/wizard
chmod u+x ./bin/wizard

echo "ok"
