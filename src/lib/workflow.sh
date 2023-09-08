#!/usr/bin/env bash
#@desc Workflow definition functions for bash scripts

source "./src/lib/log.sh"

#set -euo pipefail

#@desc      Check prerequisites for workflow.
#@ex        workflow_check_prerequisites
#@const     JQ (read-only)
#@return    255 if the prerequisites are not met
workflow_check_prerequisites () {
    log_debug "Check prerequisites for workflow"

    local status=0

    if [ -z "${WILD_CWD:-}" ]; then
        log_error "Missing WILD_CWD environment variable"
        status=1
    fi

    if [ -z "${JQ:-}" ]; then
        log_error "Missing jq command"
        status=1
    fi

    if [ $status -ne 0 ]; then
        log_fatal "Prerequisites for workflow are not met"
        return 1
    fi

    log_debug "WILD_CWD is ${WILD_CWD}"
    log_debug "jq command is ${JQ}"
}

#@desc      Check if the workflow definition file exists.
#@ex        workflow_check_workflow_definition_path
#@arg       workflow_definition_path: path to the workflow definition file
#@stderr    Writes the fatal message to stdout if the workflow definition file does not exist and exit 255
#@stdout    Writes the info message to stdout if the workflow definition file exists
#@return    workflow_definition_path: path to the workflow definition file
workflow_check_workflow_definition_path() {
    local path="${1:-}"

    log_debug "Check workflow definition path"

    if [ -z "${path}" ]; then
        log_info "No workflow definition path provided, using default one"
        path="config/workflow-default.json"
    fi

    if [ ! -f "${WILD_CWD}/${path}" ]; then
        log_fatal "Workflow definition file in ${path} does not exist"
        exit 1
    fi

    log_info "Load workflow definition from ${path}"
    echo "$path"
}

#@desc      Get containers names from a JSON workflow definition.
#@ex        workflow_workflow_get_workflows_containers_names \"config/workflow-default.json\"
#@const     JQ (read-only)
#@const     workflow_definition_path (read-only)
#@stdout    Writes debug messages to stdout
#@return    All found containers names of the workflow as array
workflow_get_workflows_containers_names() {
    local workflow_definition_path="${1}"

    local containers_names=()
    while IFS= read -r line; do
        containers_names+=("$line")
    done < <("$JQ" -r '.actions[].container' "${workflow_definition_path}")

    # shellcheck disable=SC2145
    #if log_is_debug...
    log_debug "Workflow has ${#containers_names[@]} container(s):"
    for container_name in "${containers_names[@]}"; do
        log_debug "- Container name '${container_name}'"
    done

    echo "${containers_names[@]}"
}

#@desc      Load action definition from an action_id and the workflow definition file.
#@ex        workflow_load_action_definition \"action1\" \"config/workflow-default.json\"
#@const     JQ (read-only)
#@const     workflow_definition_path (read-only)
#@arg       action_id: id of the action to load
#@arg       workflow_definition_path: path to the workflow definition file
#@stdout    Writes debug messages to stdout
#@return    Action definition as an array
workflow_load_action_definition() {
    local action_id="${1:-}"
    local workflow_definition_path="${2:-}"

    local action_definition
    # shellcheck disable=SC2207
    action_definition=($("$JQ" <"${WILD_CWD}/${workflow_definition_path}" -rc ".actions[] | select(.id == \"${action_id}\")"))

    # shellcheck disable=SC2145
    log_debug "Action definition is: ${action_definition[@]}"

    echo "${action_definition[@]}"
}

# Call the load function with the specified workflow definition path
# workflow_load "config/workflow-default.json"
