#!/usr/bin/env bash
#@desc This script is used to generate documentation for bash scripts used in Wild.

set -euo pipefail

# shellcheck disable=SC1091
source lib/log.sh

#@desc Constant that marks the start of a comment line.
declare -r MARKER_COMMENT_START='#'

#@desc Constant that marks the start of an annotation.
declare -r MARKER_ANNOTATION_START="${MARKER_COMMENT_START}@"

#@desc Constant that marks a variable definition.
declare -r MARKER_VARIABLE_DEFINITION='='

#@desc Constant that marks a function definition.
declare -r MARKER_FUNCTION_DEFINITION='()'

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

declare -r LABEL_LIBRARY='LIBRARY'

declare -r LABEL_CONSTANT='GLOBAL VARIABLES'

declare -r LABEL_FUNCTION='FUNCTIONS'

declare -A buffer=()

#@desc Reset the buffer.
doc::_buffer_reset() {
    buffer=()
}

#@desc Write a value to the buffer by key.
#@arg $1 The key to write.
#@arg $2 The value to write.
doc::_buffer_write() {
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
doc::buffer_read() {
    local key="$1"

    if [ ${buffer[$key]+_} ]; then
        echo "${buffer[$key]}"
    else
        echo ""
    fi
}

doc::buffer_print() {
    for key in "${!buffer[@]}"; do
        echo "$key: ${buffer[$key]}"
    done
}

doc::startswith() {
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

doc::contains() {
    local line="$1"
    local pattern="$2"

    case $line in
    *"$pattern"*) true ;;
    *) false ;;
    esac
}

doc::_write_constant() {
    constant_name=$(doc::buffer_read "$ANNOTATION_CONSTANT")
    constant_description=$(doc::buffer_read "$ANNOTATION_DESCRIPTION")

    {
        echo -e "### \`${constant_name}\`\n"
        echo -e "* *${constant_description}*\n"
    } 

    doc::_buffer_reset
}

doc::_write_multiple_annotation() {
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

doc::_write_function() {
    local function_name="$1"
    local line_number="$2"

    local function_description
    function_description=$(doc::buffer_read "$ANNOTATION_DESCRIPTION")
    local function_arguments
    function_arguments=$(doc::buffer_read "$ANNOTATION_ARGUMENT")
    local function_example
    function_example=$(doc::buffer_read "$ANNOTATION_EXAMPLE")
    local function_stdout
    function_stdout=$(doc::buffer_read "$ANNOTATION_STDOUT")
    local function_return
    function_return=$(doc::buffer_read "$ANNOTATION_RETURN")

    {
        echo -e "### \`$function_name\`\n"

        [ -n "${function_description}" ] && echo -e "* $function_description\n"

        doc::_write_multiple_annotation "Argument" true "${function_arguments}"
        [ -n "${function_example}" ] && echo -e "* Example\n"
        [ -n "${function_example}" ] && echo -e "$function_example\n"
        doc::_write_multiple_annotation "Output" false "${function_stdout}"
        doc::_write_multiple_annotation "Return Code" false "${function_return}"
    } 

    doc::_buffer_reset
}

doc::main() {

    if test "$*" = ""; then
        echo "Usage: $0 <space separated list of bash scripts>"
        exit 1
    fi

    log::info "Starting the documentation generation..."

    for file in "$@"; do

        mardown_file="docs/${file%.*}.md"
        mardown_file_dir=$(dirname "$mardown_file")

        line_number=0
        if test ! -f "$file"; then
            log::fatal "Fatal bazooka: ${file} does not exist"
            exit 2
        fi

        log::info "Starting the documentation generation of script ${file}..."

        is_shebang=true
        has_constant_section=false
        is_function=false
        has_function_section=false

        while read -r line; do

            line_number=$((line_number + 1))

            log::warn "Line is: $line"

            if doc::startswith "$line" "$MARKER_COMMENT_START"; then
                log::debug "This is an annotation"

                ###### Description ######
                if doc::contains "$line" "$ANNOTATION_DESCRIPTION"; then
                    log::debug "This is a description annotation"

                    # shellcheck disable=SC2154 disable=SC2295
                    description=$(echo "${line#$ANNOTATION_DESCRIPTION}" | xargs)

                    if "$is_shebang"; then
                        log::debug "This is a shebang"
                        echo -e "# ${LABEL_LIBRARY} \`$file\`\n"
                        echo -e "${description}\n"
                        is_shebang=false
                    else
                        doc::_buffer_write "$ANNOTATION_DESCRIPTION" "$description"
                    fi

                    log::debug "Description: $description"

                ###### Constant ######
                elif doc::contains "$line" "$ANNOTATION_CONSTANT"; then
                    log::debug "This is a constant annotation"

                ###### Argument ######
                elif doc::contains "$line" "$ANNOTATION_ARGUMENT"; then
                    log::debug "This is an argument annotation"

                    # shellcheck disable=SC2295
                    argument=$(echo "${line#$ANNOTATION_ARGUMENT}" | xargs)
                    argument_name=$(echo "$argument" | cut -d ':' -f1 | xargs)
                    argument_description=$(echo "$argument" | cut -d ':' -f2 | xargs)
                    log::debug "Argument name: $argument_name, description: $argument_description"
                    doc::_buffer_write "$ANNOTATION_ARGUMENT" "\`${argument_name}\`: ${argument_description}"

                ###### Example ######
                elif doc::contains "$line" "$ANNOTATION_EXAMPLE"; then
                    log::debug "This is an example annotation"

                    # shellcheck disable=SC2295
                    example="\
\`\`\`bash\n\
$(echo "${line#$ANNOTATION_EXAMPLE}" | xargs)\n\
\`\`\`"
                    log::debug "Example: $example"
                    doc::_buffer_write "$ANNOTATION_EXAMPLE" "$example"

                ###### Stdout ######
                elif doc::contains "$line" "$ANNOTATION_STDOUT"; then
                    log::debug "This is a stdout annotation"

                    # shellcheck disable=SC2154 disable=SC2295
                    stdout=$(echo "${line#$ANNOTATION_STDOUT}" | xargs)
                    log::debug "Stdout: $stdout"
                    doc::_buffer_write "$ANNOTATION_STDOUT" "\`stdout\`: ${stdout}"

                ###### Return ######
                elif doc::contains "$line" "$ANNOTATION_RETURN"; then
                    log::debug "This is a return annotation"    

                    # shellcheck disable=SC2154 disable=SC2295
                    return=$(echo "${line#$ANNOTATION_RETURN}" | xargs)
                    log::debug "Return: $return"
                    doc::_buffer_write "$ANNOTATION_RETURN" "\`return\`: ${return}"
                fi

            ###### starts with blank ######
            elif doc::startswith "$line" " "; then
                continue

            ###### Variable ######
            elif doc::contains "$line" "$MARKER_VARIABLE_DEFINITION"; then
                log::debug "This is a variable definition"

                if ! "$has_constant_section" && ! "$is_function"; then
                    echo -e "## ${LABEL_CONSTANT}\n"
                    has_constant_section=true
                fi

                if ! "$is_function"; then
                    # shellcheck disable=SC2295
                    variable=$(echo "$line" | cut -d "$MARKER_VARIABLE_DEFINITION" -f1 | xargs)
                    name=${variable##* }
                    doc::_buffer_write "$ANNOTATION_CONSTANT" "\`${name}\`"
                    doc::_write_constant
                fi
                
            ###### Function ######
            elif doc::contains "$line" "$MARKER_FUNCTION_DEFINITION"; then
                log::debug "This is a function definition"
                is_function=true

                if ! "$has_function_section"; then
                    echo -e "## ${LABEL_FUNCTION}\n"
                    has_function_section=true
                fi

                #doc::buffer_print

                function_name=$(echo "$line" | cut -d '(' -f1 | xargs)
                doc::_write_function "$function_name" "$line_number"
            fi

            ###### Block ######
            if doc::startswith "$line" "$MARKER_BLOCK_END"; then
                log::debug "This is a block end"
                
                is_function=false
                doc::_buffer_reset
            fi


        done <"$file" >"$mardown_file"

        echo '---------------------------------------' >>"$mardown_file"
        relpath=$(realpath --relative-to="$mardown_file_dir" "$file")
        echo "*Generated from [$file](${relpath}) ($(date +"%d.%m.%Y %H:%M:%S"))*" >>"$mardown_file"

    done
}

doc::main "$@"
