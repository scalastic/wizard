# shellcheck disable=SC2148
#
# Description: Unit tests for gendoc.sh

Describe 'Script Documentation Generation'

    setup() { 
        export WILD_CWD="${PWD}"
        export LOG_PATH="${WILD_CWD}/tmp/log"
        export LOG_LEVEL="${LOG_LEVEL_DEBUG}"
    }
    BeforeAll 'setup'

    It 'generates documentation'
        When call "./src/lib/ext/gendoc.sh" "./src/lib/ext/gendoc.sh"

        Dump

        #The stdout should include "## LIBRARY"
        #The stdout should include "## GLOBAL VARIABLES"
        #The stdout should include "## FUNCTIONS"
        The status should be success
    End

    It 'generates documentation for a script with shebang'

        Skip "Skip!"

        When run "./src/lib/ext/gendoc.sh" "./src/lib/ext/gendoc.sh"
        The output should include "# LIBRARY \`script_with_shebang.sh\`"
        The status should be success
    End

    It 'generates documentation for a script with constant'

        Skip "Skip!"

        When run "./src/lib/ext/gendoc.sh" "./src/lib/ext/gendoc.sh"
        The output should include "### \`CONSTANT_NAME\`"
        The output should include "* *Constant description*"
        The status should be success
    End

    It 'generates documentation for a script with argument'

        Skip "Skip!"

        When run "./src/lib/ext/gendoc.sh" "./src/lib/ext/gendoc.sh"
        The output should include "### \`function_name\`"
        The output should include "* Function description"
        The output should include "Argument"
        The output should include "  1. \`argument_name\`: Argument description"
        The status should be success
    End

    It 'generates documentation for a script with example'

        Skip "Skip!"

        When run "./src/lib/ext/gendoc.sh" "./src/lib/ext/gendoc.sh"
        The output should include "### \`function_name\`"
        The output should include "* Function description"
        The output should include "* Example"
        The output should include "\`\`\`bash"
        The output should include "Example code"
        The output should include "\`\`\`"
        The status should be success
    End

    It 'generates documentation for a script with stdout'

        Skip "Skip!"

        When run "./src/lib/ext/gendoc.sh" "./src/lib/ext/gendoc.sh"
        The output should include "### \`function_name\`"
        The output should include "* Function description"
        The output should include "Output"
        The output should include "  * \`stdout\`: Standard output description"
        The status should be success
    End

    It 'generates documentation for a script with return value'

        Skip "Skip!"

        When run "./src/lib/ext/gendoc.sh" "./src/lib/ext/gendoc.sh"
        The output should include "### \`function_name\`"
        The output should include "* Function description"
        The output should include "Return Code"
        The output should include "  * \`return\`: Return value description"
        The status should be success
    End
  
End
