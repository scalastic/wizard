# Library `lib/doc_test.sh`

This script is used to test documentation generation for bash scripts used in Wild.

## Constants

#### `LOG_LEVEL_DEBUG`

* *Constant that stores log level debug definition.*

#### `LOG_LEVEL`

* *Constant that stores current log level.*

#### `LOG_LEVELS`

* *Constant that stores all log level definitions.*

#### `LOG_LEVEL_DEBUG_COLOR`

* *Constant that stores log level debug color definition.*

#### `LOG_COLOR_OFF`

* *Constant that stores log level color off definition.*

## Functions

### `_log`

* *Log a message.*
* **Example**

    ```bash
    _log "$LOG_LEVEL_DEBUG" "This is a debug message" "$LOG_LEVEL_DEBUG_COLOR" "$LOG_COLOR_OFF"
    ```
* **Arguments**

    1. `level`: log level
    1. `message`: message to log
    1. `color`: color to use for the message
    1. `color_off`: color to use to turn off the color

### `log::debug`

* *Log a debug message.*
* **Example**

    ```bash
    log::debug "This is a debug message"
    ```
* **Arguments**

    1. `message`: message to log
* **Returns**

    1. `stdout`: Writes the debug message to stdout


---------------------------------------
*Generated from [lib/doc_test.sh](../../lib/doc_test.sh) (18.04.2023 02:12:59)*
