# shellcheck disable=SC2148
#
# Description: Unit tests for sequence.sh

Describe "Test that tooling.sh"

    Include "./lib/log.sh"

    setup() { 
        export LOG_LEVEL="${LOG_LEVEL_INFO}"
        export WILD_CWD="${PWD}"
    }
    BeforeAll 'setup'

    Include "./lib/tooling.sh"

    Describe "tooling::_check_command"

        It "returns true when the command is available on the system"

            When call tooling::_check_command "ls"

            The status should be success
            The status should eq 0
        End

        It "returns false when the command is not available on the system"

            When call tooling::_check_command "FAKE_COMMAND"

            The status should be failure
            The status should eq 1
        End

    End

    Describe "tooling::_get_command"

        It "returns the command when the command is available on the system"

            When call tooling::_get_command "ls"

            The status should be success
            The output should eq "$(command -v ls)"
        End

        It "returns an empty string when the command is not available on the system"

            When call tooling::_get_command "FAKE_COMMAND"

            The status should be failure
            The output should eq ""
        End

    End

    Describe "tooling::set_jq"

        # shellcheck disable=SC2317
        tooling::_check_command() { if [ "$1" = "jq" ]; then { true; } else { false;} fi }
        # shellcheck disable=SC2317
        tooling::_get_command() { echo "FAKE_JQ"; }

        It "returns a status success when jq is available on the system"

            When call tooling::set_jq

            The status should be success
            The variable JQ should eq "FAKE_JQ"
            The variable IS_DOCKERIZED_JQ should eq "false"
            The stderr should be present # for logs redirected into stderr
        End

        # shellcheck disable=SC2317
        tooling::_check_command() { if [ "$1" = "docker" ]; then { true; } else { false;} fi }
        tooling::_get_command() { echo "FAKE_DOCKER"; }

        It "returns a status success when docker is available on the system"

            When call tooling::set_jq

            The status should be success
            The variable JQ should eq "FAKE_DOCKER run -i scalastic/wild:latest"
            The variable IS_DOCKERIZED_JQ should eq "true"
            The stderr should be present # for logs redirected into stderr
        End

        tooling::_check_command() { false; }

        It "returns a status failure when jq and docker are not available on the system"

            When run tooling::set_jq

            The status should be failure
            The stderr should be present
            The stderr should include "No jq command found! Please install jq or docker."
        End

    End

End