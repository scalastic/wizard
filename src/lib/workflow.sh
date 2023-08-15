#!/usr/bin/env bash
#@desc Workflow definition functions for bash scripts

source "./src/lib/log.sh"

#set -euo pipefail

#@desc      Check prerequisites for workflow.
#@ex        workflow_check_prerequisites
#@const     JQ (read-only)
#@return    255 if the prerequisites are not met
workflow_check_prerequisites () {
    log::debug "Check prerequisites for workflow"

    local status=0

    if [ -z "${WILD_CWD:-}" ]; then
        log::error "Missing WILD_CWD environment variable"
        status=1
    fi

    if [ -z "${JQ:-}" ]; then
        log::error "Missing jq command"
        status=1
    fi

    if [ $status -ne 0 ]; then
        log::fatal "Prerequisites for workflow are not met"
        return 1
    fi

    log::debug "WILD_CWD is ${WILD_CWD}"
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

#@desc      Get containers' names from a JSON workflow definition.
#@ex        workflow_workflow_get_workflows_containers_names \"config/workflow-default.json\"
#@const     JQ (read-only)
#@const     workflow_definition_path (read-only)
#@stdout    Writes debug messages to stdout
#@return    All found containers' names of the workflow as array
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

#@desc      Load step definition from an item and the workflow definition file.
#@ex        workflow_load_step_definition \"step1\" \"config/workflow-default.json\"
#@const     JQ (read-only)
#@const     workflow_definition_path (read-only)
#@arg       item_id: id of the item to load
#@arg       workflow_definition_path: path to the workflow definition file
#@stdout    Writes debug messages to stdout
#@return    Step definition as array
workflow_load_workflow_definition() {
    local item_id="${1:-}"
    local workflow_definition_path="${2:-}"

    local step_definition
    # shellcheck disable=SC2207
    step_definition=($("$JQ" <"${WILD_CWD}/${workflow_definition_path}" -rc ".actions[] | select(.id == \"${item_id}\")"))

    # shellcheck disable=SC2145
    log_debug "Step definition is: ${step_definition[@]}"

    echo "${step_definition[@]}"
}

#@desc      Load step values as environment variables from a step definition as JSON.
#@ex        workflow_load_step_values \"[\"id\":\"step1\",\"name\":\"Step 1\",\"description\":\"Step 1 description\",\"type\":\"command\",\"command\":\"echo 'Step 1'\"]\"
#@const     JQ (read-only)
#@arg       step_definition: step definition to load
#@stdout    Writes debug messages to stdout
#@return    The step values
workflow_load_step_values() {
    local step_definition="${1}"
    local initializer
    # shellcheck disable=SC2128 disable=SC2086
    initializer=$("$JQ" -r <<<$step_definition 'to_entries[] | "\(.key)=\(.value)"' | tr -d \")

    log_debug "Step values are: $initializer"

    eval "$initializer"
}

#@desc      Iterate over workflow.
#@ex        workflow_iterate_over_workflow \"config/workflow-default.json\" \"action1 action2 action3\"
#@const     workflow_definition_path (read-only)
#@arg       workflow_definition_path: path to the workflow definition file
#@arg       workflows_id: array of workflows id
workflow_iterate_over_workflow() {
    local workflow_definition_path="${1}"
    shift
    local workflows_id=("$@")

    for item in "${workflows_id[@]}"; do
        log_info "Loop over step $item"

        local step_definition
        # shellcheck disable=SC2207
        step_definition=($(workflow_load_workflow_definition "$item" "$workflow_definition_path"))

        # shellcheck disable=SC2128 disable=SC2145
        log_debug "Step definition is ${step_definition[@]}"

        workflow_load_step_values "${step_definition[@]}"
    done
}

#@desc      Load workflow definition from a file.
#@ex        workflow_load \"config/workflow-default.json\"
#@const     JQ (read-only)
#@arg       workflow_definition_path: path to the workflow definition file
#@stdout    Writes the workflow definition details to stdout
#workflow_load() {
#    local workflow_definition_path="${1:-}"
#
#    workflow_definition_path=$(workflow_check_workflow_definition_path "$workflow_definition_path")
#    workflow_check_prerequisites
#
#    local workflows_id=()
#    # shellcheck disable=SC2207
#    workflows_id+=($(workflow_get_workflows_id "$workflow_definition_path"))
#
#    # shellcheck disable=SC2145
#    log_debug "Caller Workflows id are: ${workflows_id[@]}"
#    log_debug "Length Workflows id are: ${#workflows_id[@]}"
#
#    workflow_iterate_over_workflow "$workflow_definition_path" "${workflows_id[@]}"
#}

# Call the load function with the specified workflow definition path
# workflow_load "config/workflow-default.json"
