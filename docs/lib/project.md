# Library `lib/project.sh`

Project definition functions for bash scripts

* **Example**

    ```bash
    project::get_configuration_path
    ```
## Constants

## Functions

### `project::get_configuration_path`

* **Arguments**

    1. `path`: path to the project configuration file
* **Returns**

    1. `stdout`: path to the project configuration file (default: config/project.sh)


### `project::print_configuration`

* *Print the project configuration.*
* **Example**

    ```bash
    project::print_configuration
    ```
* **Arguments**

    1. `None`: None
* **Returns**

    1. `stdout`: the project configuration


### `_architecture_print_layers`

* *Print the project architecture layers.*
* **Example**

    ```bash
    _architecture_print_layers
    ```
* **Arguments**

    1. `None`: None

---------------------------------------
*Generated from [lib/project.sh](../../lib/project.sh) (18.04.2023 03:37:19)*
