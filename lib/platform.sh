#!/usr/bin/env bash

set -euo pipefail

PLATFORM_JENKINS="JENKINS"
PLATFORM_GITLAB="GITLAB"
PLATFORM_LOCAL="LOCAL"

_is_jenkins() {
    if [[ -v JENKINS_URL && -v BUILD_ID && -v WORKSPACE ]]; then
        echo true
        return
    fi
    echo false
}

_is_gitlab() {
    echo false
}

_is_local() {
    if [ "$(_is_jenkins)" = "false" ] && [ "$(_is_gitlab)" = "false" ]; then
        echo true
        return
    fi
    echo false
}

get_platform() {
    if [[ "$(_is_jenkins)" = "true" ]]; then
        echo "${PLATFORM_JENKINS}"
    elif [[ "$(_is_gitlab)" = "true" ]]; then
        echo "${PLATFORM_GITLAB}"
    elif [[ "$(_is_local)" = "true" ]]; then
        echo "${PLATFORM_LOCAL}"
    fi
}
