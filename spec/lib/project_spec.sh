# shellcheck disable=SC2148
#
# Description: Unit tests for project.sh

Describe "Test that project.sh"

    Include "./src/lib/log.sh"
    Include "./src/lib/project.sh"

    setup() { 
        export WILD_CWD="${PWD}"
        export LOG_PATH="${WILD_CWD}/tmp/log"
        export LOG_LEVEL="${LOG_LEVEL_INFO}"
        export CONFIG_PATH="${WILD_CWD}/test/config"
    }

    BeforeAll 'setup'

    Describe "project_get_configuration_path"

        It "returns the default configuration path if no path is specified"
            export CONFIG_PATH="${WILD_CWD}/config"
            When call project_get_configuration_path
            The status should be success
            The output should include "config/workflow-default.json"
            The error should include "No project configuration file specified, use default"
        End

        It "returns the specified configuration path if a path is specified"
            export CONFIG_PATH="${WILD_CWD}/test/config"
            When call project_get_configuration_path "${CONFIG_PATH}/workflow-action.json"
            The status should be success
            The output should include "${CONFIG_PATH}/workflow-action.json"
            The error should include "Read project configuration"
        End

        It "exits if the specified configuration path does not exist"
            When run project_get_configuration_path "${CONFIG_PATH}/a_bad_project.json"
            The status should be failure
            The status should eq 1
            The output should eq ""
            The error should include "Project configuration file does not exist: ${CONFIG_PATH}/a_bad_project.json"
        End

    End

End