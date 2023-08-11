#!/usr/bin/env bash
#
# Measure Cyclomatic Complexity metrics of shell scripts
# This script is for development purposes.

set -eu

sources() {

  find src -type f -not -path "*lib/ext*" -name '*.sh'
}

src/lib/ext/shellmetrics -s bash --color $(sources)