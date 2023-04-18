# Library `lib/sequence.sh`

Sequence definition functions for bash scripts

* *Check prerequisites for sequence.*
* **Example**

    ```bash
    sequence::_check_prerequisites
    ```
## Constants

## Functions

### `sequence::_check_prerequisites`

* **Arguments**

    1. `None`: None
* **Returns**

    1. `stdout`: Writes the fatal message to stdout if prerequisites are not met and exit 255


### `sequence::_check_sequence_definition_path`

* *Check if the sequence definition file exists.*
* **Example**

    ```bash
    sequence::_check_sequence_definition_path
    ```
* **Arguments**

    1. `sequence_definition_path`: path to the sequence definition file
* **Returns**

    1. `stdout`: Writes the info message to stdout if the sequence definition file exists


### `sequence::_load_sequences_id`

* *Load sequences id from a file.*
* **Example**

    ```bash
    sequence::_load_sequences_id "config/sequence-default.json"
    ```
* **Returns**

    1. `stdout`: Writes debug messages to stdout


### `sequence::_load_step_definition`

* *Load step definition from an item and the sequence definition file.*
* **Example**

    ```bash
    sequence::_load_step_definition "step1" "config/sequence-default.json"
    ```
* **Arguments**

    1. `item_id`: id of the item to load
    1. `sequence_definition_path`: path to the sequence definition file
* **Returns**

    1. `stdout`: Writes debug messages to stdout


### `sequence::_load_step_values`

* *Load step values as environment variables from a step definition as JSON.*
* **Example**

    ```bash
    sequence::_load_step_values "[id:step1,name:Step 1,description:Step 1 description,type:command,command:echo 'Step 1']"
    ```
* **Arguments**

    1. `step_definition`: step definition to load
* **Returns**

    1. `stdout`: Writes debug messages to stdout


### `sequence::_iterate_over_sequence`

* *Iterate over sequence.*
* **Example**

    ```bash
    sequence::_iterate_over_sequence "config/sequence-default.json" "step1 step2 step3"
    ```
* **Arguments**

    1. `sequence_definition_path`: path to the sequence definition file
    1. `sequences_id`: array of sequences id
* **Returns**

    1. `stdout`: None


### `sequence::load`

* *Load sequence definition from a file.*
* **Example**

    ```bash
    sequence::load "config/sequence-default.json"
    ```
* **Arguments**

    1. `sequence_definition_path`: path to the sequence definition file
* **Returns**

    1. `stdout`: Writes the sequence definition details to stdout


---------------------------------------
*Generated from [lib/sequence.sh](../../lib/sequence.sh) (18.04.2023 03:37:21)*
