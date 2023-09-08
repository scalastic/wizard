# shellcheck disable=SC2148
#
# Description: Unit tests for workflow.sh

Describe "Test that workflow.sh"

    setup() {
        export WILD_CWD="${PWD}"
        export LOG_PATH="${WILD_CWD}/tmp/log"
        export LOG_LEVEL="${LOG_LEVEL_DEBUG}"
        export CONFIG_PATH="${WILD_CWD}/config"

        mkdir -p "${WILD_CWD}/tmp/config"
    }

    BeforeAll 'setup'

    Include "./src/lib/workflow.sh"

    Describe "workflow_check_prerequisites"

        It "returns a status success when all prerequisites are met"

            BeforeRun 'JQ=FAKE_JQ'

            When run workflow_check_prerequisites

            The status should be success
            The stderr should be present # for logs redirected into stderr
        End

        It "returns a status failure when WILD_CWD is not set"

            BeforeRun 'unset WILD_CWD'
            BeforeRun 'JQ=FAKE_JQ'

            When run workflow_check_prerequisites

            The stderr should be present
            The status should be failure
        End

        It "returns a status failure when JQ is not set"

            When run workflow_check_prerequisites

            The stderr should be present
            The status should be failure
        End

    End

    Describe "workflow_check_workflow_definition_path"

        It "returns a status success when no workflow definition is specified and default one is present on filesystem"

            When call workflow_check_workflow_definition_path

            The status should be success
            The stdout should eq "config/workflow-default.json"
            The stderr should be present # for logs redirected into stderr
        End

        It "returns a status success when a workflow definition is specified and is present on filesystem"

            FAKE_DEFINITION_PATH="tmp/config/fake_definition.json"

            BeforeRun "touch ${FAKE_DEFINITION_PATH}"
            AfterRun "rm ${FAKE_DEFINITION_PATH}"

            When run workflow_check_workflow_definition_path "${FAKE_DEFINITION_PATH}"

            The status should be success
            The output should eq "${FAKE_DEFINITION_PATH}"
            The stderr should be present # for logs redirected into stderr
        End

        It "returns a status failure when a workflow definition is specified but is not present on filesystem"

            When run workflow_check_workflow_definition_path "tmp/config/fake_definition.json"

            The status should be failure
            The stderr should be present # for logs redirected into stderr
        End

    End

    Describe "workflow_get_workflows_containers_names"

        Include "./src/lib/tooling.sh"

        It "returns all actions containers' names from a workflow definition file"

            TEST_WORKFLOW_DEFINITION_FILENAME="test/config/test-workflow-default.json"

            BeforeRun "tooling_set_jq"

            When run workflow_get_workflows_containers_names "${TEST_WORKFLOW_DEFINITION_FILENAME}"

            The status should be success
            The output should eq "wild maven"
            The stderr should be present # for logs redirected into stderr
        End

    End

    Describe "workflow_load_action_definition"

        Include "./src/lib/tooling.sh"

        It "returns an action definition from a workflow definition file"

            TEST_WORKFLOW_DEFINITION_FILENAME="test/config/test-workflow-default.json"

            BeforeRun "tooling_set_jq"

            When run workflow_load_action_definition "action1" "${TEST_WORKFLOW_DEFINITION_FILENAME}"

            The status should be success
            The output should eq "{\"id\":\"action1\",\"name\":\"Action 1\",\"container\":\"wild\",\"script\":\"test/action/bash-version.sh\"}"
            The stderr should be present # for logs redirected into stderr
        End

    End

End
