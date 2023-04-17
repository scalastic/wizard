#!/usr/bin/env bash
#@lib log
#@desc This script is used to generate documentation for bash scripts used in Wild.


set -euo pipefail

# shellcheck disable=SC1091
source lib/log.sh

COMMENT_LINE_START='#'
COMMENT_ANNOTATION_START="${COMMENT_LINE_START}@"
COMMENT_ANNOTATION_LIBRARY='lib'
COMMENT_ANNOTATION_DESCRIPTION='desc'
COMMENT_ANNOTATION_CONSTANT='const'
COMMENT_ANNOTATION_ARGUMENT='arg'
COMMENT_ANNOTATION_EXAMPLE='example'
COMMENT_ANNOTATION_STDOUT='stdout'
COMMENT_ANNOTATION_STDERR='stderr'
VARIABLE_DEFINITION_MARKER='='
FUNCTION_DEFINITION_MARKER='()'

is_comment=false
is_library=false
is_first_constant=true
is_constant=false
is_first_function=true
is_function=false
is_first_argument=true
is_first_return=true

buffer=""

doc::add_to_buffer() {
    buffer="${buffer}${1}\n"
}

doc::write_buffer() {
    if test "$buffer" = ""; then
        return
    fi
    log::debug "Writing buffer: $buffer"
    echo -e "$buffer"
    buffer=""
}

doc::startswith() {
    local line="$1"
    local pattern="$2"

    shopt -s extglob # on
    line="${line##*( )}"
    shopt -u extglob # off

    case $line in 
        "$pattern"*) true;; 
        *) false;; 
    esac
}

doc::contains() {
    local line="$1"
    local pattern="$2"

    case $line in 
        *"$pattern"*) true;; 
        *) false;; 
    esac
}

doc::add_library_to_buffer() {
    local line="$1"
    local file="$2"
    # shellcheck disable=SC2295
    lib="${line#$COMMENT_ANNOTATION_LIBRARY}"
    if test "$lib" = ""; then
        log::info "Library name not specified"
        lib="$file"
    fi
    log::info "Library $lib"
    doc::add_to_buffer "# Library \`$lib\`\n"
}

doc::main() {
    if test "$*" = ""; then
        echo "Usage: $0 <space-seperated list of bash scripts>"
        exit 1
    fi

    log::info "Starting the documentation generation..."

    for file in "$@"; do

        mardown_file="docs/${file%.*}.md"
        mardown_file_dir=$(dirname "$mardown_file")
        mkdir -p "$mardown_file_dir"

        log::debug "Processing $file..."

        line_number=0
        if test ! -f "$file"; then
            log::fatal "Fatal bazooka: $file does not exist"
            exit 255
        fi

        while read line; do

            line_number=$(( line_number + 1))

            log::warn "Line is: $line"

            # COMMENT ANNOTATION 
            if doc::startswith "$line" "$COMMENT_ANNOTATION_START"; then

                log::debug "Found comment at line $line_number"

                is_comment=true

                # shellcheck disable=SC2295
                comment_type="${line#$COMMENT_ANNOTATION_START}"

                # LIBRARY ANNONTATION
                if doc::startswith "$comment_type" "$COMMENT_ANNOTATION_LIBRARY"; then
                    is_library=true
                    # shellcheck disable=SC2094
                    doc::add_library_to_buffer "$comment_type" "$file"
                # CONSTANT ANNOTATION
                elif doc::startswith "$comment_type" "$COMMENT_ANNOTATION_CONSTANT"; then
                    is_constant=true
                    if "$is_first_constant"; then
                        doc::add_to_buffer "## Constants"
                        doc::write_buffer
                        is_first_constant=false
                    fi
                # DESCRIPTION ANNOTATION
                elif doc::startswith "$comment_type" "$COMMENT_ANNOTATION_DESCRIPTION"; then
                    # shellcheck disable=SC2295
                    description=$( echo "${comment_type#$COMMENT_ANNOTATION_DESCRIPTION}" | xargs)
                    log::info "Description: $description"
                    if "$is_library"; then
                        doc::add_to_buffer "${description}"
                    elif "is_function"; then
                        doc::add_to_buffer "* **Description**\n\n *${description}*"
                    else
                        doc::add_to_buffer "* *${description}*"
                    fi
                # ARGUMENT ANNOTATION
                elif doc::startswith "$comment_type" "$COMMENT_ANNOTATION_ARGUMENT"; then
                    log::debug "Found argument annotation"

                    if "$is_first_argument"; then
                        doc::add_to_buffer "* **Arguments**\n"
                        is_first_argument=false
                    fi

                    is_function=true
                    # shellcheck disable=SC2295
                    argument=$( echo "${comment_type#$COMMENT_ANNOTATION_ARGUMENT}" | xargs)
                    argument_name=$(echo "$argument" | cut -d ':' -f1 | xargs)
                    argument_description=$(echo "$argument" | cut -d ':' -f2 | xargs)
                    log::info "Argument: $argument"
                    doc::add_to_buffer "    1. \`${argument_name}\`: ${argument_description}"

                # EXAMPLE ANNOTATION
                elif doc::startswith "$comment_type" "$COMMENT_ANNOTATION_EXAMPLE"; then
                    log::debug "Found example annotation"

                    # shellcheck disable=SC2295
                    example=$( echo "${comment_type#$COMMENT_ANNOTATION_EXAMPLE}" | xargs)
                    log::info "Example: $example"
                    doc::add_to_buffer "* **Example**\n"
                    doc::add_to_buffer "    \`\`\`bash"
                    doc::add_to_buffer "    $example"
                    doc::add_to_buffer "    \`\`\`"
                # STDOUT ANNOTATION
                elif doc::startswith "$comment_type" "$COMMENT_ANNOTATION_STDOUT"; then
                    log::debug "Found stdout annotation"

                    if "$is_first_return"; then
                        doc::add_to_buffer "* **Returns**"
                        is_first_return=false
                    fi

                    # shellcheck disable=SC2295
                    stdout=$( echo "${comment_type#$COMMENT_ANNOTATION_STDOUT}" | xargs)
                    log::info "Stdout: $stdout"
                    doc::add_to_buffer "\n    1. \`stdout\`: ${stdout}\n"
                fi

            # NOT A COMMENT LINE
            elif ! doc::startswith "$line" "$COMMENT_LINE_START"; then

                is_library=false
                is_comment=false
                is_function=false

                # VARIABLE DEFINITION
                if doc::contains "$line" "$VARIABLE_DEFINITION_MARKER"; then
                    if "$is_constant"; then
                        log::error "Found variable definition in line $line at $line_number"
                        
                        var_name=$(echo "$line" | cut -d '=' -f1 | xargs)
                        echo -e "#### \`${var_name}\`\n"
                        doc::write_buffer
                        is_constant=false
                    fi
                # FUNCTION DEFINITION
                elif doc::contains "$line" "$FUNCTION_DEFINITION_MARKER"; then
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
                    doc::write_buffer
                fi

            fi

        done < "$file" > "$mardown_file"

        echo '---------------------------------------' >> "$mardown_file"
        echo "*Generated from $file ($(date +"%d.%m.%Y %H:%M:%S"))*" >> "$mardown_file"
    done
    #exit 0
}

doc::main "$@"
