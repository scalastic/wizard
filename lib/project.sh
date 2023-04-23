#!/usr/bin/env bash
#@desc Project definition functions for bash scripts

set -euo pipefail


#@desc      Get the project configuration path.
#@ex        project::get_configuration_path
#@arg       path: path to the project configuration file
#@stdout    path to the project configuration file (default: config/project.sh)
# shellcheck disable=SC2120
project::get_configuration_path() {
    local path

    log::info "Read project configuration"

    if [ -z "${1:-}" ]; then
        log::info "No project configuration file specified, use default"
        path="config/project.sh"
    else
        path="$1"
    fi

    if [ ! -f "$path" ]; then
        log::fatal "Project configuration file does not exist: $path"
        exit 255
    fi

    echo "$path"
}


#@desc      Print the project configuration.
#@ex        project::print_configuration
#@const     name: project name (read-only)
#@const     version: project version (read-only)
#@const     description: project description (read-only)
#@const     project: project configuration (read-only)
#@const     project_language: project language configuration (read-only)
#@const     project_build: project build configuration (read-only)
#@const     project_architecture: project architecture configuration (read-only)
#@const     project_architecture_layers: project architecture layers configuration (read-only)
#@stdout    The project configuration
#@return    1 if the project configuration is not defined yet
project::print_configuration() {

    set +u

    # shellcheck disable=SC2086
    if [ -z ${name} ] && [ -z ${project[$name]} ]; then
        log::error "Project configuration is not defined yet"
        set -u
        return 1
    else
        # shellcheck disable=SC2154
        log::banner \
            "Project name: ${project[$name]}\n" \
            "Project version: ${project[$version]}\n" \
            "Project language: ${project_language[$name]} ${project_language[$version]}\n" \
            "Project build: ${project_build[$name]} ${project_build[$version]}\n" \
            "Project architecture: ${project_architecture[$name]} (${project_architecture[$description]})\n" \
            "Project architecture layers:\n" \
            "$(project::_architecture_print_layers)"
    fi

    set -u
}


#@desc      Print the project architecture layers.
#@ex        project::_architecture_print_layers
#@const     project_architecture_layers: project architecture layers configuration (read-only)
#@stdout    The project architecture layers as a formatted string
project::_architecture_print_layers() {
    local result=""

    # shellcheck disable=SC2154
    for (( i=0; i<$((${#project_architecture_layers[@]}/3)); i++ )); do
        result+="\t${i}. ${project_architecture_layers[$i,$name]} (${project_architecture_layers[$i,$description]}) - ${project_architecture_layers[$i,$path]}\n"
    done

    echo "$result"
}
