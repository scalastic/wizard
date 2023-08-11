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
        export CONFIG_PATH="${WILD_CWD}/config"
    }

    BeforeAll 'setup'

    Describe "project::get_configuration_path"

        It "returns the default configuration path if no path is specified"
            When call project::get_configuration_path
            The status should be success
            The output should include "config/project.sh"
            The error should include "No project configuration file specified, use default"
        End

        It "returns the specified configuration path if a path is specified"
            When call project::get_configuration_path "${CONFIG_PATH}/project.sh"
            The status should be success
            The output should include "${CONFIG_PATH}/project.sh"
            The error should include "Read project configuration"
        End

        It "exits if the specified configuration path does not exist"
            When run project::get_configuration_path "${CONFIG_PATH}/a_bad_project.sh"
            The status should be failure
            The status should eq 255
            The output should eq ""
            The error should include "Project configuration file does not exist: ${CONFIG_PATH}/a_bad_project.sh"
        End

    End

End