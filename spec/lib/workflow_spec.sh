# shellcheck disable=SC2148
#
# Description: Unit tests for workflow.sh

Describe "Test that workflow.sh"

    Include "./src/lib/log.sh"

    setup() {
        export WILD_CWD="${PWD}"
        export LOG_PATH="${WILD_CWD}/tmp/log"
        export LOG_LEVEL="${LOG_LEVEL_INFO}"
        export CONFIG_PATH="${WILD_CWD}/config"
    }
    BeforeAll 'setup'

    Include "./src/lib/workflow.sh"

    Describe "workflow::_check_prerequisites"

        It "returns a status success when all prerequisites are met"

            BeforeRun 'JQ=FAKE_JQ'

            When run workflow::_check_prerequisites

            The status should be success
        End

        It "returns a status failure when WILD_CWD is not set"

            BeforeRun 'unset WILD_CWD'
            BeforeRun 'JQ=FAKE_JQ'

            When run workflow::_check_prerequisites

            The stderr should be present
            The status should be failure
        End

        It "returns a status failure when JQ is not set"

            When run workflow::_check_prerequisites

            The stderr should be present
            The status should be failure
        End

    End

    Describe "workflow::_check_workflow_definition_path"

        It "returns a status success when no workflow definition is specified and default one is present on filesystem"

            When call workflow::_check_workflow_definition_path

            The status should be success
            The stdout should eq "config/workflow-default.json"
            The stderr should be present # for logs redirected into stderr
        End

        It "returns a status success when a workflow definition is specified and is present on filesystem"

            FAKE_DEFINITION_PATH="config/fake_definition.json"

            BeforeRun "touch ${FAKE_DEFINITION_PATH}"
            AfterRun "rm ${FAKE_DEFINITION_PATH}"

            When run workflow::_check_workflow_definition_path "${FAKE_DEFINITION_PATH}"

            The status should be success
            The output should eq "${FAKE_DEFINITION_PATH}"
            The stderr should be present # for logs redirected into stderr
        End

        It "returns a status failure when a workflow definition is specified but is not present on filesystem"

            When run workflow::_check_workflow_definition_path "config/fake_definition.json"

            The status should be failure
            The stderr should be present # for logs redirected into stderr
        End

    End

    Describe "workflow::_get_workflows_containers_names"

        Include "./src/lib/tooling.sh"

        It "returns all actions containers' names from a workflow definition file"

            FAKE_DEFINITION_PATH="test/config/workflow-default.json"

            BeforeRun "tooling::set_jq"
            #BeforeRun "echo '{\"id\": \"fake_id\", \"name\": \"Fake name\", \"version\": \"1.0.0\", \"actions\": []}' > ${FAKE_DEFINITION_PATH}"
            #AfterRun "rm ${FAKE_DEFINITION_PATH}"

            When run workflow::_get_workflows_containers_names "${FAKE_DEFINITION_PATH}"

            The status should be success
            The output should eq "bash maven"
            The stderr should be present # for logs redirected into stderr
        End

    End

    Describe "workflow::_load_workflow_definition"

        Include "./src/lib/tooling.sh"

        It "returns an action definition from a workflow definition file"

            FAKE_DEFINITION_PATH="config/fake_definition.json"

            BeforeRun "tooling::set_jq"
            BeforeRun echo "'{\"id\": \"fake_id\", \"name\": \"Fake name\", \"version\": \"1.0.0\", \"actions\": [ ' \
            '{
                  \"id\": \"action1\",
                  \"name\": \"Action 1\",
                  \"container\": \"bash\",
                  \"action\": \"test/action/test.sh\"
                }' \
            ']}' > ${FAKE_DEFINITION_PATH}"
            AfterRun "rm ${FAKE_DEFINITION_PATH}"

            When run workflow::_load_workflow_definition "action1" "${FAKE_DEFINITION_PATH}"

            The status should be success
            The output should eq "{\"id\":\"action1\",\"name\":\"Action 1\",\"container\":\"bash\",\"action\":\"test/action/test.sh\"}"
            The stderr should be present # for logs redirected into stderr
        End

    End

    Describe "workflow::_load_step_values"

        Include "./src/lib/tooling.sh"

        It "returns step values from a workflow definition file"

            FAKE_DEFINITION_PATH="config/fake_definition.json"

            BeforeCall "tooling::set_jq"
            step_definition="{\"id\":\"action1\",\"name\":\"Action 1\",\"container\":\"bash\",\"action\":\"test/action/test.sh\"}"

            # shellcheck disable=SC2154
            When call workflow::_load_step_values "${step_definition}"

            The status should be success
            The variable id should eq "action1"
            The variable name should eq "Action 1"
            The variable container should eq "bash"
            The variable action should eq "test/action/test.sh"
            The stderr should be present # for logs redirected into stderr
        End

    End

    Describe "workflow::_iterate_over_workflow"

        Include "./src/lib/tooling.sh"

        It "returns a status success when all steps are executed"

            FAKE_DEFINITION_PATH="config/fake_definition.json"

            BeforeCall "tooling::set_jq"
            BeforeCall "echo '{\"actions\": [ \
                {\"id\": \"action1\", \"name\": \"Action 1\", \"container\": \"bash\", \"action\": \"test/action/test.sh\"}, \
                {\"id\": \"action2\", \"name\": \"Action 2\", \"container\": \"maven\", \"action\": \"test/action/maven.sh\"} \
                ]}' > ${FAKE_DEFINITION_PATH}"
            AfterCall "rm ${FAKE_DEFINITION_PATH}"

            actions_id=("action1" "action2")

            # shellcheck disable=SC2154
            When call workflow::_iterate_over_workflow "${FAKE_DEFINITION_PATH}" "${actions_id[@]}"

            The status should be success
            The stderr should include "Loop over step action1"
            The stderr should include "Loop over step action2"
            The variable id should eq "action2"
            The variable name should eq "Action 2"
            The variable container should eq "maven"
            The variable action should eq "test/action/maven.sh"
        End

    End

    Describe "workflow::load"

        Include "./src/lib/tooling.sh"

        It "returns a status success when all steps are executed"

            FAKE_DEFINITION_PATH="config/fake_definition.json"

            BeforeCall "tooling::set_jq"
            BeforeCall "echo '{\"actions\": [ \
                {\"id\": \"action1\", \"name\": \"Action 1\", \"container\": \"bash\", \"action\": \"test/action/test.sh\"}, \
                {\"id\": \"action2\", \"name\": \"Action 2\", \"container\": \"maven\", \"action\": \"test/action/maven.sh\"} \
                ]}' > ${FAKE_DEFINITION_PATH}"
            AfterCall "rm ${FAKE_DEFINITION_PATH}"

            # shellcheck disable=SC2154
            When call workflow::load "${FAKE_DEFINITION_PATH}"

            The status should be success
            The stderr should include "Loop over step action1"
            The stderr should include "Loop over step action2"
            The variable id should eq "action2"
            The variable name should eq "Action 2"
            The variable container should eq "maven"
            The variable action should eq "test/action/maven.sh"
        End

    End

End
