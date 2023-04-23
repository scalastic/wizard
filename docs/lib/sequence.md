# LIBRARY `lib/sequence.sh`

Sequence definition functions for bash scripts

## FUNCTIONS

### `sequence::_check_prerequisites 🚫 (private)`

* Check prerequisites for sequence.

* Example

```bash
sequence::_check_prerequisites
```

* Return Code

  * `return`: 255 if the prerequisites are not met

### `sequence::_check_sequence_definition_path 🚫 (private)`

* Check if the sequence definition file exists.

* Argument

  1. `sequence_definition_path`: path to the sequence definition file

* Example

```bash
sequence::_check_sequence_definition_path
```

* Output

  * `stdout`: Writes the info message to stdout if the sequence definition file exists

* Return Code

  * `return`: sequence_definition_path: path to the sequence definition file

### `sequence::_load_sequences_id 🚫 (private)`

* Load sequences id from a file.

* Example

```bash
sequence::_load_sequences_id "config/sequence-default.json"
```

* Output

  * `stdout`: Writes debug messages to stdout

* Return Code

  * `return`: id of the sequences as array

### `sequence::_load_step_definition 🚫 (private)`

* Load step definition from an item and the sequence definition file.

* Argument

  1. `item_id`: id of the item to load

  1. `sequence_definition_path`: path to the sequence definition file

* Example

```bash
sequence::_load_step_definition "step1" "config/sequence-default.json"
```

* Output

  * `stdout`: Writes debug messages to stdout

* Return Code

  * `return`: Step definition as array

### `sequence::_load_step_values 🚫 (private)`

* Load step values as environment variables from a step definition as JSON.

* Argument

  1. `step_definition`: step definition to load

* Example

```bash
sequence::_load_step_values "["id":"step1","name":"Step 1","description":"Step 1 description","type":"command","command":"echo Step 1"]"
```

* Output

  * `stdout`: Writes debug messages to stdout

* Return Code

  * `return`: The step values

### `sequence::_iterate_over_sequence 🚫 (private)`

* Iterate over sequence.

* Argument

  1. `sequence_definition_path`: path to the sequence definition file

  1. `sequences_id`: array of sequences id

* Example

```bash
sequence::_iterate_over_sequence "config/sequence-default.json" "step1 step2 step3"
```

### `sequence::load ✅ (public)`

* Load sequence definition from a file.

* Argument

  1. `sequence_definition_path`: path to the sequence definition file

* Example

```bash
sequence::load "config/sequence-default.json"
```

* Output

  * `stdout`: Writes the sequence definition details to stdout

---------------------------------------
*Generated from [lib/sequence.sh](../../lib/sequence.sh) on 23.04.2023         (writen with ✨ by [gendoc](../../lib/ext/gendoc.sh))*
