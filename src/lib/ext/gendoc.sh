#!/usr/bin/env bash
#@desc This script is used to generate documentation for bash scripts used in Wild.

set -euo pipefail

# shellcheck disable=SC1091
source ./src/lib/log.sh

#@desc Constant that marks the start of a comment line.
declare -r MARKER_COMMENT_START='#'

#@desc Constant that marks a variable definition.
declare -r MARKER_VARIABLE_DEFINITION='='

#@desc Constant that marks a function definition.
declare -r MARKER_FUNCTION_DEFINITION='()'

#@desc Constant that marks a private function definition.
declare -r MARKER_FUNCTION_PRIVATE='__'

#@desc Constant that marks the end of a block.
declare -r MARKER_BLOCK_END='}'

#@desc Constant that defines a desciption annotation.
declare -r ANNOTATION_DESCRIPTION='#@desc'

#@desc Constant that defines a constant annotation.
declare -r ANNOTATION_CONSTANT='#@const'

#@desc Constant that defines an argument annotation.
declare -r ANNOTATION_ARGUMENT='#@arg'

#@desc Constant that defines an example annotation.
declare -r ANNOTATION_EXAMPLE='#@ex'

#@desc Constant that defines a stdout annotation.
declare -r ANNOTATION_STDOUT='#@stdout'

#@desc Constant that defines a return annotation.
declare -r ANNOTATION_RETURN='#@return'

#@desc Constant that defines the library label.
declare -r LABEL_LIBRARY='LIBRARY'

#@desc Constant that defines the constant label.
declare -r LABEL_CONSTANT='GLOBAL VARIABLES'

#@desc Constant that defines the function label.
declare -r LABEL_FUNCTION='FUNCTIONS'

declare -A buffer=()

#@desc Reset the buffer.
doc__buffer_reset() {
    buffer=()
}

#@desc Write a value to the buffer by key.
#@arg $1 The key to write.
#@arg $2 The value to write.
doc__buffer_write() {
    local key="$1"
    local value="$2"

    if [ ${buffer[$key]+_} ]; then
        buffer[$key]="${buffer[$key]}|$value"
    else
        buffer[$key]="$value"
    fi
}

#@desc Read a value from the buffer by key.
#@arg $1 The key to read.
#@return The value of the key.
doc_buffer_read() {
    local key="$1"

    if [ ${buffer[$key]+_} ]; then
        echo "${buffer[$key]}"
    else
        echo ""
    fi
}

#@desc Print the buffer as key, value pairs.
#@stdout The buffer content
doc_buffer_print() {
    for key in "${!buffer[@]}"; do
        echo "$key: ${buffer[$key]}"
    done
}

#@desc Check if a line starts with a pattern.
#@arg $1 The line to check.
#@arg $2 The pattern to check.
#@return 0 if the line starts with the pattern
#@return 1 otherwise.
doc_startswith() {
    local line="$1"
    local pattern="$2"

    shopt -s extglob # on
    line="${line##*( )}"
    shopt -u extglob # off

    case $line in
    "$pattern"*) true ;;
    *) false ;;
    esac
}

#@desc Check if a line contains a pattern.
#@arg $1 The line to check.
#@arg $2 The pattern to check.
#@return 0 if the line contains the pattern
#@return 1 otherwise.
doc_contains() {
    local line="$1"
    local pattern="$2"

    case $line in
    *"$pattern"*) true ;;
    *) false ;;
    esac
}

#@desc Writes the constant part of the documentation.
#@stdout The constant part of the documentation.
doc__write_constant() {
    constant_name=$(doc_buffer_read "$ANNOTATION_CONSTANT")
    constant_description=$(doc_buffer_read "$ANNOTATION_DESCRIPTION")

    {
        echo -e "### \`${constant_name}\`\n"
        echo -e "* *${constant_description}*\n"
    } 

    doc__buffer_reset
}

doc__write_multiple_annotation() {
    local label="$1"
    local ordered_values="$2"
    local separated_values="$3"

    if [ -n "${separated_values}" ]; then
        echo -e "* ${label}\n"
        IFS='|' read -ra values  <<<"$separated_values"
        for value in "${values[@]}"; do
            [ "$ordered_values" == "true" ] && echo -e "  1. $value\n" || echo -e "  * $value\n"
        done
    fi
}

doc__write_function() {
    local function_name="$1"
    local line_number="$2"

    local function_description
    function_description=$(doc_buffer_read "$ANNOTATION_DESCRIPTION")
    local function_arguments
    function_arguments=$(doc_buffer_read "$ANNOTATION_ARGUMENT")
    local function_example
    function_example=$(doc_buffer_read "$ANNOTATION_EXAMPLE")
    local function_stdout
    function_stdout=$(doc_buffer_read "$ANNOTATION_STDOUT")
    local function_return
    function_return=$(doc_buffer_read "$ANNOTATION_RETURN")

    {
        echo -e "### \`$function_name\`\n"

        [ -n "${function_description}" ] && echo -e "* $function_description\n"

        doc__write_multiple_annotation "Argument" true "${function_arguments}"
        [ -n "${function_example}" ] && echo -e "* Example\n"
        [ -n "${function_example}" ] && echo -e "$function_example\n"
        doc__write_multiple_annotation "Output" false "${function_stdout}"
        doc__write_multiple_annotation "Return Code" false "${function_return}"
    } 

    doc__buffer_reset
}

doc_main() {

    if test "$*" = ""; then
        echo "Usage: $0 <space separated list of bash scripts>"
        exit 1
    fi

    log_debug "Starting the documentation generation..."

    for file in "$@"; do

        mardown_file="docs/${file%.*}.md"
        mardown_file_dir=$(dirname "$mardown_file")
        mkdir -p "$mardown_file_dir"

        line_number=0
        if test ! -f "$file"; then
            log_fatal "Fatal bazooka: ${file} does not exist"
            exit 2
        fi

        log_debug "Starting the documentation generation of script ${file}..."

        is_shebang=true
        has_constant_section=false
        is_function=false
        has_function_section=false

        while read -r line; do

            line_number=$((line_number + 1))

            log_debug "Line is: $line"

            if doc_startswith "$line" "$MARKER_COMMENT_START"; then
                log_debug "This is an annotation"

                ###### Description ######
                if doc_contains "$line" "$ANNOTATION_DESCRIPTION"; then
                    log_debug "This is a description annotation"

                    # shellcheck disable=SC2154 disable=SC2295
                    description=$(echo "${line#$ANNOTATION_DESCRIPTION}" | xargs)

                    if "$is_shebang"; then
                        log_debug "This is a shebang"
                        echo -e "# ${LABEL_LIBRARY} \`$file\`\n"
                        echo -e "${description}\n"
                        is_shebang=false
                    else
                        doc__buffer_write "$ANNOTATION_DESCRIPTION" "$description"
                    fi

                    log_debug "Description: $description"

                ###### Constant ######
                elif doc_contains "$line" "$ANNOTATION_CONSTANT"; then
                    log_debug "This is a constant annotation"

                ###### Argument ######
                elif doc_contains "$line" "$ANNOTATION_ARGUMENT"; then
                    log_debug "This is an argument annotation"

                    # shellcheck disable=SC2295
                    argument=$(echo "${line#$ANNOTATION_ARGUMENT}" | xargs)
                    argument_name=$(echo "$argument" | cut -d ':' -f1 | xargs)
                    argument_description=$(echo "$argument" | cut -d ':' -f2 | xargs)
                    log_debug "Argument name: $argument_name, description: $argument_description"
                    doc__buffer_write "$ANNOTATION_ARGUMENT" "\`${argument_name}\`: ${argument_description}"

                ###### Example ######
                elif doc_contains "$line" "$ANNOTATION_EXAMPLE"; then
                    log_debug "This is an example annotation"

                    # shellcheck disable=SC2295
                    example="\
\`\`\`bash\n\
$(echo "${line#$ANNOTATION_EXAMPLE}" | xargs)\n\
\`\`\`"
                    log_debug "Example: $example"
                    doc__buffer_write "$ANNOTATION_EXAMPLE" "$example"

                ###### Stdout ######
                elif doc_contains "$line" "$ANNOTATION_STDOUT"; then
                    log_debug "This is a stdout annotation"

                    # shellcheck disable=SC2154 disable=SC2295
                    stdout=$(echo "${line#$ANNOTATION_STDOUT}" | xargs)
                    log_debug "Stdout: $stdout"
                    doc__buffer_write "$ANNOTATION_STDOUT" "\`stdout\`: ${stdout}"

                ###### Return ######
                elif doc_contains "$line" "$ANNOTATION_RETURN"; then
                    log_debug "This is a return annotation"

                    # shellcheck disable=SC2154 disable=SC2295
                    return=$(echo "${line#$ANNOTATION_RETURN}" | xargs)
                    log_debug "Return: $return"
                    doc__buffer_write "$ANNOTATION_RETURN" "\`return\`: ${return}"
                fi

            ###### starts with blank ######
            elif doc_startswith "$line" " "; then
                continue

            ###### Variable ######
            elif doc_contains "$line" "$MARKER_VARIABLE_DEFINITION"; then
                log_debug "This is a variable definition"

                if ! "$has_constant_section" && ! "$is_function"; then
                    echo -e "## ${LABEL_CONSTANT}\n"
                    has_constant_section=true
                fi

                if ! "$is_function"; then
                    # shellcheck disable=SC2295
                    variable=$(echo "$line" | cut -d "$MARKER_VARIABLE_DEFINITION" -f1 | xargs)
                    name=${variable##* }
                    doc__buffer_write "$ANNOTATION_CONSTANT" "\`${name}\`"
                    doc__write_constant
                fi
                
            ###### Function ######
            elif doc_contains "$line" "$MARKER_FUNCTION_DEFINITION"; then
                log_debug "This is a function definition"
                is_function=true

                if ! "$has_function_section"; then
                    echo -e "## ${LABEL_FUNCTION}\n"
                    has_function_section=true
                fi

                function_name=$(echo "$line" | cut -d '(' -f1 | xargs)

                if doc_contains "$function_name" "$MARKER_FUNCTION_PRIVATE"; then
                    log_debug "This is a private function definition"
                    doc__write_function "$function_name 🚫 (private)" "$line_number"
                else 
                    log_debug "This is a public function definition"
                    doc__write_function "$function_name ✅ (public)" "$line_number"
                fi
                
            fi

            ###### Block ######
            if doc_startswith "$line" "$MARKER_BLOCK_END"; then
                log_debug "This is a block end"
                
                is_function=false
                doc__buffer_reset
            fi


        done <"$file" >"$mardown_file"

        echo '---------------------------------------' >>"$mardown_file"
        relpath=$(realpath --relative-to="$mardown_file_dir" "$file")
        gendoc_relpath=$(realpath --relative-to="$mardown_file_dir" "src/lib/ext/gendoc.sh")
        echo "*Generated from [$file](${relpath}) on $(date +"%d.%m.%Y") \
        (writen with ✨ by [gendoc](${gendoc_relpath}))*" >>"$mardown_file"

    done
}

# Check if the script is being executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    doc_main "$@"
fi

