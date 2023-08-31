# shellcheck disable=SC2148
#
# Description: Unit tests for sequence.sh

Describe "Test that tooling.sh"

    Include "./src/lib/log.sh"

    setup() {
        export LOG_PATH="${PWD}/log"
        export LOG_LEVEL="${LOG_LEVEL_INFO}"
        export WILD_CWD="${PWD}"
    }
    BeforeAll 'setup'

    Include "./src/lib/tooling.sh"

    Describe "tooling__check_command"

        It "returns true when the command is available on the system"

            When call tooling__check_command "ls"

            The status should be success
            The status should eq 0
        End

        It "returns false when the command is not available on the system"

            When call tooling__check_command "FAKE_COMMAND"

            The status should be failure
            The status should eq 1
        End

    End

    Describe "tooling__get_command"

        It "returns the command when the command is available on the system"

            When call tooling__get_command "ls"

            The status should be success
            The output should eq "$(command -v ls)"
        End

        It "returns an empty string when the command is not available on the system"

            When call tooling__get_command "FAKE_COMMAND"

            The status should be failure
            The output should eq ""
        End

    End

    Describe "tooling_set_jq"

        # shellcheck disable=SC2317
        tooling__check_command() { if [ "$1" = "jq" ]; then { true; } else { false;} fi }
        # shellcheck disable=SC2317
        tooling__get_command() { echo "FAKE_JQ"; }

        It "returns a status success when jq is available on the system"

            When call tooling_set_jq

            The status should be success
            The variable JQ should eq "FAKE_JQ"
            The variable IS_DOCKERIZED_JQ should eq "false"
            The stderr should be present # for logs redirected into stderr
        End

        # shellcheck disable=SC2317
        tooling__check_command() { if [ "$1" = "docker" ]; then { true; } else { false;} fi }
        tooling__get_command() { echo "FAKE_DOCKER"; }

        It "returns a status success when docker is available on the system"

            When call tooling_set_jq

            The status should be success
            The variable JQ should eq "FAKE_DOCKER run -i scalastic/wild:latest"
            The variable IS_DOCKERIZED_JQ should eq "true"
            The stderr should be present # for logs redirected into stderr
        End

        tooling__check_command() { false; }

        It "returns a status failure when jq and docker are not available on the system"

            When run tooling_set_jq

            The status should be failure
            The stderr should be present
            The stderr should include "No jq command found! Please install jq or docker."
        End

    End

End