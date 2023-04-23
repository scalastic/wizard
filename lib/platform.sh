#!/usr/bin/env bash
#@desc Platform functions for bash scripts

set -euo pipefail

#@desc Constant that stores platform jenkins definition.
declare -r PLATFORM_JENKINS="JENKINS"

#@desc Constant that stores platform gitlab definition.
declare -r PLATFORM_GITLAB="GITLAB"

#@desc Constant that stores platform local definition.
declare -r PLATFORM_LOCAL="LOCAL"

#@desc      Test if the script is running on jenkins.
#@ex        platform::_is_jenkins
#@const     JENKINS_URL (read-only)
#@const     BUILD_ID (read-only)
#@const     WORKSPACE (read-only)
#@return    true if the script is running on jenkins
#@return    false otherwise
platform::_is_jenkins() {
    if [ -v JENKINS_URL ] && [ -v BUILD_ID ] && [ -v WORKSPACE ]; then
        true
    else
        false
    fi
}

#@desc      Test if the script is running on gitlab.
#@ex        project::_is_local
#@return    true if the script is running on gitlab
#@return    false otherwise
platform::_is_gitlab() {
    false
}

#@desc      Test if the script is running locally.
#@ex        project::_is_local
#@return    true if the script is running locally
#@return    false otherwise
platform::_is_local() {
    if platform::_is_jenkins || platform::_is_gitlab; then
        false
    else
        true
    fi
}

#@desc      Get the platform where the script is running.
#@ex        platform::get_platform
#@const     PLATFORM_JENKINS (read-only)
#@const     PLATFORM_GITLAB (read-only)
#@const     PLATFORM_LOCAL (read-only)
#@stdout    The platform where the script is running
platform::get_platform() {
    if platform::_is_jenkins; then
        echo "${PLATFORM_JENKINS}"
    elif platform::_is_gitlab; then
        echo "${PLATFORM_GITLAB}"
    elif platform::_is_local; then
        echo "${PLATFORM_LOCAL}"
    fi
}
