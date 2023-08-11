# LIBRARY `src/lib/tooling.sh`

Check if a command exists

## FUNCTIONS

### `tooling::_check_command 🚫 (private)`

* Argument

  1. `The command to check`: The command to check

* Example

```bash
tooling::_check_command jq
```

* Output

  * `stdout`: true if the command exists otherwise false

### `tooling::_get_command 🚫 (private)`

* Argument

  1. `The command to get the path`: The command to get the path

* Example

```bash
tooling::_get_command jq
```

* Output

  * `stdout`: The path of the command

### `tooling::set_jq ✅ (public)`

* Set the jq command

* Example

```bash
tooling::set_jq
```

---------------------------------------
*Generated from [src/lib/tooling.sh](../../../src/lib/tooling.sh) on 11.08.2023         (writen with ✨ by [gendoc](../../../src/lib/ext/gendoc.sh))*
