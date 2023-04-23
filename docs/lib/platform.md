# LIBRARY `lib/platform.sh`

Platform functions for bash scripts

## GLOBAL VARIABLES

### ``PLATFORM_JENKINS``

* *Constant that stores platform jenkins definition.*

### ``PLATFORM_GITLAB``

* *Constant that stores platform gitlab definition.*

### ``PLATFORM_LOCAL``

* *Constant that stores platform local definition.*

## FUNCTIONS

### `platform::_is_jenkins`

* Test if the script is running on jenkins.

* Example

```bash
platform::_is_jenkins
```

* Return Code

  * `return`: true if the script is running on jenkins

  * `return`: false otherwise

### `platform::_is_gitlab`

* Test if the script is running on gitlab.

* Example

```bash
project::_is_local
```

* Return Code

  * `return`: true if the script is running on gitlab

  * `return`: false otherwise

### `platform::_is_local`

* Test if the script is running locally.

* Example

```bash
project::_is_local
```

* Return Code

  * `return`: true if the script is running locally

  * `return`: false otherwise

### `platform::get_platform`

* Get the platform where the script is running.

* Example

```bash
platform::get_platform
```

* Output

  * `stdout`: The platform where the script is running

---------------------------------------
*Generated from [lib/platform.sh](../../lib/platform.sh) (23.04.2023 16:48:37)*
