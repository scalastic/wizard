#!/usr/bin/env bash
#@lib
#@desc Platform functions for bash scripts

set -euo pipefail

#######################################
#@const
#@desc Constant that stores platform jenkins definition.
#######################################
PLATFORM_JENKINS="JENKINS"

#######################################
#@const
#@desc Constant that stores platform gitlab definition.
#######################################
PLATFORM_GITLAB="GITLAB"

#######################################
#@const
#@desc Constant that stores platform local definition.
#######################################
PLATFORM_LOCAL="LOCAL"

#######################################
#@desc Test if the script is running on jenkins.
#@example _is_jenkins
# Globals:
#@const JENKINS_URL (read-only)
#@const BUILD_ID (read-only)
#@const WORKSPACE (read-only)
# Arguments:
#@arg None
# Outputs:
#@stdout true if the script is running on jenkins, false otherwise
#######################################
_is_jenkins() {
    if [[ -v JENKINS_URL && -v BUILD_ID && -v WORKSPACE ]]; then
        echo true
        return
    fi
    echo false
}

#######################################
#@desc Test if the script is running on gitlab.
#@example _is_gitlab
# Globals:
#@const None
# Arguments:
#@arg None
# Outputs:
#@stdout true if the script is running on gitlab, false otherwise
#######################################
_is_gitlab() {
    echo false
}

#######################################
#@desc Test if the script is running locally.
#@example _is_local
# Globals:
#@const None
# Arguments:
#@arg None
# Outputs:
#@stdout true if the script is running locally, false otherwise
#######################################
_is_local() {
    if [ "$(_is_jenkins)" = "false" ] && [ "$(_is_gitlab)" = "false" ]; then
        echo true
        return
    fi
    echo false
}

#######################################
#@desc Get the platform where the script is running.
#@example _get_platform
# Globals:
#@const PLATFORM_JENKINS (read-only)
#@const PLATFORM_GITLAB (read-only)
#@const PLATFORM_LOCAL (read-only)
# Arguments:
#@arg None
# Outputs:
#@stdout the platform where the script is running
#######################################
get_platform() {
    if [[ "$(_is_jenkins)" = "true" ]]; then
        echo "${PLATFORM_JENKINS}"
    elif [[ "$(_is_gitlab)" = "true" ]]; then
        echo "${PLATFORM_GITLAB}"
    elif [[ "$(_is_local)" = "true" ]]; then
        echo "${PLATFORM_LOCAL}"
    fi
}
