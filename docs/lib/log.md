# LIBRARY `lib/log.sh`

Logger functions for bash scripts

## GLOBAL VARIABLES

### ``LOG_LEVEL_DEBUG``

* *Constant that stores log level debug definition.*

### ``LOG_LEVEL_INFO``

* *Constant that stores log level info definition.*

### ``LOG_LEVEL_WARN``

* *Constant that stores log level warn definition.*

### ``LOG_LEVEL_ERROR``

* *Constant that stores log level error definition.*

### ``LOG_LEVEL_FATAL``

* *Constant that stores log level fatal (bazooka) definition.*

### ``LOG_LEVEL``

* *Constant that stores current log level.*

### ``LOG_LEVELS``

* *Array constant that stores all log level definitions.*

### ``LOG_LEVEL_DEBUG_COLOR``

* *Constant that stores log level debug color definition.*

### ``LOG_LEVEL_INFO_COLOR``

* *Constant that stores log level info color definition.*

### ``LOG_LEVEL_WARN_COLOR``

* *Constant that stores log level warn color definition.*

### ``LOG_LEVEL_ERROR_COLOR``

* *Constant that stores log level error color definition.*

### ``LOG_LEVEL_FATAL_COLOR``

* *Constant that stores log level fatal color definition.*

### ``LOG_COLOR_OFF``

* *Constant that stores log level color off definition.*

## FUNCTIONS

### `log::_log`

* Log a message.

* Argument

  1. `level`: log level

  1. `message`: message to log

  1. `color`: color to use for the message

  1. `color_off`: color to use to turn off the color

* Example

```bash
log::_log "$LOG_LEVEL_DEBUG" "This is a debug message" "$LOG_LEVEL_DEBUG_COLOR" "$LOG_COLOR_OFF"
```

### `log::_banner`

* Log a banner message.

* Argument

  1. `message`: message to log

  1. `color`: color to use for the message

  1. `color_off`: color to use to turn off the color

* Example

```bash
log::_banner "This is a banner message" "$LOG_LEVEL_INFO_COLOR" "$LOG_COLOR_OFF"
```

* Output

  * `stdout`: Writes the banner message to stdout

### `log::debug`

* Log a debug message.

* Argument

  1. `message`: message to log

* Example

```bash
log::debug "This is a debug message"
```

* Output

  * `stdout`: Writes the debug message to stdout

### `log::info`

* Log an info message.

* Argument

  1. `message`: message to log

* Example

```bash
log::info "This is an info message"
```

* Output

  * `stdout`: Writes the info message to stdout

### `log::warn`

* Log a warning message.

* Argument

  1. `message`: message to log

* Example

```bash
log::warn "This is a warning message"
```

* Output

  * `stdout`: Writes the warning message to stdout

### `log::error`

* Log an error message.

* Argument

  1. `message`: message to log

* Example

```bash
log::error "This is an error message"
```

* Output

  * `stdout`: Writes the error message to stdout

### `log::fatal`

* Log a fatal message.

* Argument

  1. `message`: message to log

* Example

```bash
log::fatal "This is a fatal message"
```

* Output

  * `stdout`: Writes the fatal message to stdout

### `log::banner`

* Log a banner message.

* Argument

  1. `message`: message to log

* Example

```bash
log::banner "This is a banner message"
```

* Output

  * `stdout`: Writes the banner message to stdout

---------------------------------------
*Generated from [lib/log.sh](../../lib/log.sh) (23.04.2023 11:52:09)*
