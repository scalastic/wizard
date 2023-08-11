# LIBRARY `./src/lib/ext/gendoc.sh`

This script is used to generate documentation for bash scripts used in Wild.

## GLOBAL VARIABLES

### ``MARKER_COMMENT_START``

* *Constant that marks the start of a comment line.*

### ``MARKER_VARIABLE_DEFINITION``

* *Constant that marks a variable definition.*

### ``MARKER_FUNCTION_DEFINITION``

* *Constant that marks a function definition.*

### ``MARKER_FUNCTION_PRIVATE``

* *Constant that marks a private function definition.*

### ``MARKER_BLOCK_END``

* *Constant that marks the end of a block.*

### ``ANNOTATION_DESCRIPTION``

* *Constant that defines a desciption annotation.*

### ``ANNOTATION_CONSTANT``

* *Constant that defines a constant annotation.*

### ``ANNOTATION_ARGUMENT``

* *Constant that defines an argument annotation.*

### ``ANNOTATION_EXAMPLE``

* *Constant that defines an example annotation.*

### ``ANNOTATION_STDOUT``

* *Constant that defines a stdout annotation.*

### ``ANNOTATION_RETURN``

* *Constant that defines a return annotation.*

### ``LABEL_LIBRARY``

* *Constant that defines the library label.*

### ``LABEL_CONSTANT``

* *Constant that defines the constant label.*

### ``LABEL_FUNCTION``

* *Constant that defines the function label.*

### ``buffer``

* **

## FUNCTIONS

### `doc::_buffer_reset 🚫 (private)`

* Reset the buffer.

### `doc::_buffer_write 🚫 (private)`

* Write a value to the buffer by key.

* Argument

  1. `$1 The key to write.`: $1 The key to write.

  1. `$2 The value to write.`: $2 The value to write.

### `doc::buffer_read ✅ (public)`

* Read a value from the buffer by key.

* Argument

  1. `$1 The key to read.`: $1 The key to read.

* Return Code

  * `return`: The value of the key.

### `doc::buffer_print ✅ (public)`

* Print the buffer as key, value pairs.

* Output

  * `stdout`: The buffer content

### `doc::startswith ✅ (public)`

* Check if a line starts with a pattern.

* Argument

  1. `$1 The line to check.`: $1 The line to check.

  1. `$2 The pattern to check.`: $2 The pattern to check.

* Return Code

  * `return`: 0 if the line starts with the pattern

  * `return`: 1 otherwise.

### `doc::contains ✅ (public)`

* Check if a line contains a pattern.

* Argument

  1. `$1 The line to check.`: $1 The line to check.

  1. `$2 The pattern to check.`: $2 The pattern to check.

* Return Code

  * `return`: 0 if the line contains the pattern

  * `return`: 1 otherwise.

### `doc::_write_constant 🚫 (private)`

* Writes the constant part of the documentation.

* Output

  * `stdout`: The constant part of the documentation.

### `doc::_write_multiple_annotation 🚫 (private)`

### `doc::_write_function 🚫 (private)`

### `doc::main ✅ (public)`

---------------------------------------
*Generated from [./src/lib/ext/gendoc.sh](../../../../src/lib/ext/gendoc.sh) on 11.08.2023         (writen with ✨ by [gendoc](../../../../src/lib/ext/gendoc.sh))*
