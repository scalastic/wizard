# LIBRARY `lib/tooling.sh`

Check if a command exists

## FUNCTIONS

### `tooling::_check_command`

* Argument

  1. `The command to check`: The command to check

* Example

```bash
tooling::_check_command jq
```

* Output

  * `stdout`: true if the command exists otherwise false

### `tooling::_get_command`

* Argument

  1. `The command to get the path`: The command to get the path

* Example

```bash
tooling::_get_command jq
```

* Output

  * `stdout`: The path of the command

### `tooling::set_jq`

* Set the jq command

* Example

```bash
tooling::set_jq
```

---------------------------------------
*Generated from [lib/tooling.sh](../../lib/tooling.sh) (23.04.2023 11:52:07)*
