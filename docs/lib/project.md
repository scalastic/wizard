# LIBRARY `lib/project.sh`

Project definition functions for bash scripts

## FUNCTIONS

### `project::get_configuration_path`

* Get the project configuration path.

* Argument

  1. `path`: path to the project configuration file

* Example

```bash
project::get_configuration_path
```

* Output

  * `stdout`: path to the project configuration file (default: config/project.sh)

### `project::print_configuration`

* Print the project configuration.

* Example

```bash
project::print_configuration
```

* Output

  * `stdout`: The project configuration

* Return Code

  * `return`: 1 if the project configuration is not defined yet

### `project::_architecture_print_layers`

* Print the project architecture layers.

* Example

```bash
project::_architecture_print_layers
```

* Output

  * `stdout`: The project architecture layers as a formatted string

---------------------------------------
*Generated from [lib/project.sh](../../lib/project.sh) (23.04.2023 11:52:08)*
