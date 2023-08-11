# LIBRARY `src/lib/project.sh`

Project definition functions for bash scripts

## FUNCTIONS

### `project::get_configuration_path ✅ (public)`

* Get the project configuration path.

* Argument

  1. `path`: path to the project configuration file

* Example

```bash
project::get_configuration_path
```

* Output

  * `stdout`: path to the project configuration file (default: config/project.sh)

### `project::print_configuration ✅ (public)`

* Print the project configuration.

* Example

```bash
project::print_configuration
```

* Output

  * `stdout`: The project configuration

* Return Code

  * `return`: 1 if the project configuration is not defined yet

### `project::_architecture_print_layers 🚫 (private)`

* Print the project architecture layers.

* Example

```bash
project::_architecture_print_layers
```

* Output

  * `stdout`: The project architecture layers as a formatted string

---------------------------------------
*Generated from [src/lib/project.sh](../../../src/lib/project.sh) on 11.08.2023         (writen with ✨ by [gendoc](../../../src/lib/ext/gendoc.sh))*
