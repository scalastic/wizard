#!/usr/bin/env bash
#
# Inline Wild script and act as a wrapper.
# This script is for release purposes.

set -euo pipefail

export WILD_CWD="${PWD}"

mkdir -p ./bin
rm -f ./bin/wild
./lib/ext/./inline.sh --in-file src/wild.sh --out-file bin/wild
grep -Ev "^[[:blank:]]*#[^!]|^[[:blank:]]*$" bin/wild > bin/wild.tmp
mv bin/wild.tmp bin/wild
chmod u+x ./bin/wild

echo "ok"
