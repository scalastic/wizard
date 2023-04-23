#!/usr/bin/env bash
#@desc This script is used to generate documentation for bash scripts used in Wild.

set -euo pipefail

# shellcheck disable=SC1091
source lib/log.sh

#@const
#@desc Constant that stores the comment line start definition.
COMMENT_LINE_START='#'

#@const
#@desc Constant that stores the comment annotation start definition.
COMMENT_ANNOTATION_START="${COMMENT_LINE_START}@"

#@const
#@desc Constant that stores the comment annotation library definition.
#COMMENT_ANNOTATION_LIBRARY='lib'

#@const
#@desc Constant that stores the comment annotation description definition.
COMMENT_ANNOTATION_DESCRIPTION='desc'

#@const
#@desc Constant that stores the comment annotation constant definition.
COMMENT_ANNOTATION_CONSTANT='const'

#@const
#@desc Constant that stores the comment annotation argument definition.
COMMENT_ANNOTATION_ARGUMENT='arg'

#@const
#@desc Constant that stores the comment annotation example definition.
COMMENT_ANNOTATION_EXAMPLE='ex'

#@const
#@desc Constant that stores the comment annotation stdout definition.
COMMENT_ANNOTATION_STDOUT='stdout'

#@const
#@desc Constant that stores the comment annotation return definition.
COMMENT_ANNOTATION_RETURN='return'

#@const
#@desc Constant that stores the marker of variable.
MARKER_OF_VARIABLE='='

#@const
#@desc Constant that stores the marker of function.
MARKER_OF_FUNCTION='()'

is_comment=false
is_library=true
is_first_constant=true
is_constant=false
is_first_function=true
is_function=false
is_first_argument=true
is_first_return=true

buffer=""

#@desc Adds a line to the buffer.
#@example doc::add_to_buffer "This is a line"
#@arg $1 The line to add to the buffer.
doc::add_to_buffer() {
    buffer="${buffer}${1}\n"
}

#@desc Writes the buffer to the standard output.
#@example doc::write_buffer
doc::write_buffer() {
    if test "$buffer" = ""; then
        return
    fi
    log::debug "Writing buffer: $buffer"
    echo -e "$buffer"
    buffer=""
}

#@desc Tests if a line starts with a pattern.
#@example doc::startswith "# Test a comment line" "#"
#@arg $1 The line to test.
#@arg $2 The pattern to test.
#@return true if the line starts with the pattern, false otherwise.
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

#@desc Tests if a line contains a pattern.
#@example doc::contains "# Test a comment line" "Test"
#@arg $1 The line to test.
#@arg $2 The pattern to test.
#@return true if the line contains the pattern, false otherwise.
doc::contains() {
    local line="$1"
    local pattern="$2"

    case $line in
    *"$pattern"*) true ;;
    *) false ;;
    esac
}

#@desc Processes documentation generation for a bash script.
#@example doc::main
#@arg $1 The list of bash scripts to process as a space separated list.
#@return 1 if input paramter is missing, 2 if a file does not exist.
doc::main() {
    if test "$*" = ""; then
        echo "Usage: $0 <space separated list of bash scripts>"
        exit 1
    fi

    log::info "Starting the documentation generation..."

    for file in "$@"; do

        is_comment=false
        is_library=true
        is_first_constant=true
        is_constant=false
        is_first_function=true
        is_function=false
        is_first_argument=true
        is_first_return=true

        mardown_file="docs/${file%.*}.md"
        mardown_file_dir=$(dirname "$mardown_file")
        mkdir -p "$mardown_file_dir"

        log::debug "Processing $file..."

        line_number=0
        if test ! -f "$file"; then
            log::fatal "Fatal bazooka: $file does not exist"
            exit 2
        fi

        while read -r line; do

            line_number=$((line_number + 1))

            log::warn "Line is: $line"

            # COMMENT ANNOTATION
            if doc::startswith "$line" "$COMMENT_ANNOTATION_START"; then

                log::debug "Found comment at line $line_number"

                is_comment=true

                # shellcheck disable=SC2295
                comment_line="${line#$COMMENT_ANNOTATION_START}"

                # CONSTANT ANNOTATION @const
                if doc::startswith "$comment_line" "$COMMENT_ANNOTATION_CONSTANT"; then
                    is_constant=true

                    if "$is_first_constant"; then
                        doc::add_to_buffer "## Constants"
                        doc::write_buffer
                        is_first_constant=false
                        fi
                # DESCRIPTION ANNOTATION @desc
                elif doc::startswith "$comment_line" "$COMMENT_ANNOTATION_DESCRIPTION"; then
                    # shellcheck disable=SC2295
                    description=$(echo "${comment_line#$COMMENT_ANNOTATION_DESCRIPTION}" | xargs)
                    log::info "Description: $description"
                    if "$is_library"; then
                        doc::add_to_buffer "${description}"
                    elif "$is_function"; then
                        doc::add_to_buffer "* **Description**\n\n *${description}*"
                    else
                        doc::add_to_buffer "* *${description}*"
                    fi
                # ARGUMENT ANNOTATION @arg
                elif doc::startswith "$comment_line" "$COMMENT_ANNOTATION_ARGUMENT"; then
                    log::debug "Found argument annotation"

                    if "$is_first_argument"; then
                        doc::add_to_buffer "* **Arguments**\n"
                        is_first_argument=false
                    fi

                    is_function=true
                    # shellcheck disable=SC2295
                    argument=$(echo "${comment_line#$COMMENT_ANNOTATION_ARGUMENT}" | xargs)
                    argument_name=$(echo "$argument" | cut -d ':' -f1 | xargs)
                    argument_description=$(echo "$argument" | cut -d ':' -f2 | xargs)
                    log::info "Argument: $argument"
                    doc::add_to_buffer "    1. \`${argument_name}\`: ${argument_description}"

                # EXAMPLE ANNOTATION @ex
                elif doc::startswith "$comment_line" "$COMMENT_ANNOTATION_EXAMPLE"; then
                    log::debug "Found example annotation"

                    # shellcheck disable=SC2295
                    example=$(echo "${comment_line#$COMMENT_ANNOTATION_EXAMPLE}" | xargs)
                    log::info "Example: $example"
                    doc::add_to_buffer "* **Example**\n"
                    doc::add_to_buffer "    \`\`\`bash"
                    doc::add_to_buffer "    $example"
                    doc::add_to_buffer "    \`\`\`\n"
                # STDOUT ANNOTATION @stdout
                elif doc::startswith "$comment_line" "$COMMENT_ANNOTATION_STDOUT"; then
                    log::debug "Found stdout annotation"

                    if "$is_first_return"; then
                        doc::add_to_buffer "* **Return**"
                        is_first_return=false
                    fi

                    # shellcheck disable=SC2295
                    stdout=$(echo "${comment_line#$COMMENT_ANNOTATION_STDOUT}" | xargs)
                    log::info "Stdout: $stdout"
                    doc::add_to_buffer "  * \`stdout\`: ${stdout}\n"
                # STATUS ANNOTATION @status
                elif doc::startswith "$comment_line" "$COMMENT_ANNOTATION_RETURN"; then
                    log::debug "Found status annotation"
                    # shellcheck disable=SC2295
                    status=$(echo "${comment_line#$COMMENT_ANNOTATION_RETURN}" | xargs)
                    log::info "Status: $status"
                    doc::add_to_buffer "  * \`status\`: ${status}\n"
                fi

            # NOT A COMMENT LINE
            elif ! doc::startswith "$line" "$COMMENT_LINE_START"; then

                # shellcheck disable=SC2034
                is_comment=false
                is_function=false

                # VARIABLE DEFINITION
                if doc::contains "$line" "$MARKER_OF_VARIABLE"; then
                    if "$is_constant"; then
                        log::error "Found variable definition in line $line at $line_number"

                        var_name=$(echo "$line" | cut -d '=' -f1 | xargs)
                        echo -e "#### \`${var_name}\`\n"
                        doc::write_buffer
                        is_constant=false
                    fi
                # FUNCTION DEFINITION
                elif doc::contains "$line" "$MARKER_OF_FUNCTION"; then
                    log::error "Found function definition in line $line at $line_number"

                    if "$is_first_function"; then
                        echo -e "## Functions\n"
                        is_first_function=false
                    fi

                    function_name=$(echo "$line" | cut -d '(' -f1 | xargs)
                    echo -e "### \`${function_name}\`\n"
                    doc::write_buffer
                    is_constant=false
                    is_first_argument=true
                    is_first_return=true
                # WRITE BUFFER
                else
                    if "$is_library"; then
                        echo -e "# Library \`$file\`\n"
                        is_library=false
                    fi
                    doc::write_buffer
                fi

            fi

        done <"$file" >"$mardown_file"

        echo '---------------------------------------' >>"$mardown_file"
        relpath=$(realpath --relative-to="$mardown_file_dir" "$file")
        echo "*Generated from [$file](${relpath}) ($(date +"%d.%m.%Y %H:%M:%S"))*" >>"$mardown_file"
    done
    #exit 0
}

doc::main "$@"
