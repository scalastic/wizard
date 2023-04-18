# Library `lib/platform.sh`

Platform functions for bash scripts

## Constants

#### `PLATFORM_JENKINS`

* *Constant that stores platform jenkins definition.*

#### `PLATFORM_GITLAB`

* *Constant that stores platform gitlab definition.*

#### `PLATFORM_LOCAL`

* *Constant that stores platform local definition.*

## Functions

### `_is_jenkins`

* *Test if the script is running on jenkins.*
* **Example**

    ```bash
    _is_jenkins
    ```
* **Arguments**

    1. `None`: None
* **Returns**

    1. `stdout`: true if the script is running on jenkins, false otherwise


### `_is_gitlab`

* *Test if the script is running on gitlab.*
* **Example**

    ```bash
    _is_gitlab
    ```
* **Arguments**

    1. `None`: None
* **Returns**

    1. `stdout`: true if the script is running on gitlab, false otherwise


### `_is_local`

* *Test if the script is running locally.*
* **Example**

    ```bash
    _is_local
    ```
* **Arguments**

    1. `None`: None
* **Returns**

    1. `stdout`: true if the script is running locally, false otherwise


### `get_platform`

* *Get the platform where the script is running.*
* **Example**

    ```bash
    _get_platform
    ```
* **Arguments**

    1. `None`: None
* **Returns**

    1. `stdout`: the platform where the script is running


---------------------------------------
*Generated from [lib/platform.sh](../../lib/platform.sh) (18.04.2023 03:37:19)*
