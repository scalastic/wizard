# LIBRARY `src/lib/workflow.sh`

Workflow definition functions for bash scripts

## FUNCTIONS

### `workflow_check_prerequisites ✅ (public)`

* Check prerequisites for workflow.

* Example

```bash
workflow_check_prerequisites
```

* Return Code

  * `return`: 255 if the prerequisites are not met

### `workflow_check_workflow_definition_path ✅ (public)`

* Check if the workflow definition file exists.

* Argument

  1. `workflow_definition_path`: path to the workflow definition file

* Example

```bash
workflow_check_workflow_definition_path
```

* Output

  * `stdout`: Writes the info message to stdout if the workflow definition file exists

* Return Code

  * `return`: workflow_definition_path: path to the workflow definition file

### `workflow_get_workflows_containers_names ✅ (public)`

* Get containers names from a JSON workflow definition.

* Example

```bash
workflow_workflow_get_workflows_containers_names "config/workflow-default.json"
```

* Output

  * `stdout`: Writes debug messages to stdout

* Return Code

  * `return`: All found containers names of the workflow as array

### `workflow_load_action_definition ✅ (public)`

* Load action definition from an action_id and the workflow definition file.

* Argument

  1. `action_id`: id of the action to load

  1. `workflow_definition_path`: path to the workflow definition file

* Example

```bash
workflow_load_action_definition "action1" "config/workflow-default.json"
```

* Output

  * `stdout`: Writes debug messages to stdout

* Return Code

  * `return`: Action definition as an array

---------------------------------------
*Generated from [src/lib/workflow.sh](../../../src/lib/workflow.sh) on 08.09.2023         (writen with ✨ by [gendoc](../../../src/lib/ext/gendoc.sh))*
