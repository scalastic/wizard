# LIBRARY `src/lib/tooling.sh`

Check if a command exists

## FUNCTIONS

### `tooling__check_command 🚫 (private)`

* Argument

  1. `The command to check`: The command to check

* Example

```bash
tooling__check_command jq
```

* Output

  * `stdout`: true if the command exists otherwise false

### `tooling__get_command 🚫 (private)`

* Argument

  1. `The command to get the path`: The command to get the path

* Example

```bash
tooling__get_command jq
```

* Output

  * `stdout`: The path of the command

### `tooling_set_jq ✅ (public)`

* Set the jq command

* Example

```bash
tooling_set_jq
```

### `tooling_get_ip ✅ (public)`

---------------------------------------
*Generated from [src/lib/tooling.sh](../../../src/lib/tooling.sh) on 10.09.2023         (writen with ✨ by [gendoc](../../../src/lib/ext/gendoc.sh))*
