# shellcheck disable=SC2148
#
# Description: Unit tests for sequence.sh

Describe "Test that sequence.sh"

    Include "./src/lib/log.sh"

    setup() {
        export WILD_CWD="${PWD}"
        export LOG_PATH="${WILD_CWD}/tmp/log"
        export LOG_LEVEL="${LOG_LEVEL_INFO}"
        export CONFIG_PATH="${WILD_CWD}/config"
    }
    BeforeAll 'setup'

    Include "./src/lib/sequence.sh"

    Describe "sequence::_check_prerequisites"

        It "returns a status success when all prerequisites are met"

            BeforeRun 'JQ=FAKE_JQ'

            When run sequence::_check_prerequisites

            The status should be success
        End

        It "returns a status failure when WILD_CWD is not set"

            BeforeRun 'unset WILD_CWD'
            BeforeRun 'JQ=FAKE_JQ'

            When run sequence::_check_prerequisites

            The stderr should be present
            The status should be failure
        End

        It "returns a status failure when JQ is not set"

            When run sequence::_check_prerequisites

            The stderr should be present
            The status should be failure
        End

    End

    Describe "sequence::_check_sequence_definition_path"

        It "returns a status success when no sequence definition is specified and default one is present on filesystem"

            When call sequence::_check_sequence_definition_path

            The status should be success
            The stdout should eq "config/sequence-default.json"
            The stderr should be present # for logs redirected into stderr
        End

        It "returns a status success when a sequence definition is specified and is present on filsesystem"

            FAKE_DEFINITION_PATH="config/fake_definition.json"

            BeforeRun "touch ${FAKE_DEFINITION_PATH}"
            AfterRun "rm ${FAKE_DEFINITION_PATH}"

            When run sequence::_check_sequence_definition_path "${FAKE_DEFINITION_PATH}"

            The status should be success
            The output should eq "${FAKE_DEFINITION_PATH}"
            The stderr should be present # for logs redirected into stderr
        End

        It "returns a status failure when a sequence definition is specified but is not present on filesystem"

            When run sequence::_check_sequence_definition_path "config/fake_definition.json"

            The status should be failure
            The stderr should be present # for logs redirected into stderr
        End

    End

    Describe "sequence::_load_sequences_id"

        Include "./src/lib/tooling.sh"

        It "returns a sequence of ids from a sequence definition file"

            FAKE_DEFINITION_PATH="config/fake_definition.json"

            BeforeRun "tooling::set_jq"
            BeforeRun "echo '{\"sequence\": [{\"id\": \"fake_id_1\"}, {\"id\": \"fake_id_2\"}]}' > ${FAKE_DEFINITION_PATH}"
            AfterRun "rm ${FAKE_DEFINITION_PATH}"

            When run sequence::_load_sequences_id "${FAKE_DEFINITION_PATH}"

            The status should be success
            The output should eq "fake_id_1 fake_id_2"
            The stderr should be present # for logs redirected into stderr
        End

    End

    Describe "sequence::_load_step_definition"

        Include "./src/lib/tooling.sh"

        It "returns a step definition from a sequence definition file"

            FAKE_DEFINITION_PATH="config/fake_definition.json"

            BeforeRun "tooling::set_jq"
            BeforeRun "echo '{\"sequence\": [ \
                {\"id\": \"fake_id_1\", \"fake_step\": \"fake_value_1\"}, \
                {\"id\": \"fake_id_2\", \"fake_step\": \"fake_value_2\"} \
                ]}' > ${FAKE_DEFINITION_PATH}"
            AfterRun "rm ${FAKE_DEFINITION_PATH}"

            When run sequence::_load_step_definition "fake_id_1" "${FAKE_DEFINITION_PATH}"

            The status should be success
            The output should eq "{\"id\":\"fake_id_1\",\"fake_step\":\"fake_value_1\"}"
            The stderr should be present # for logs redirected into stderr
        End

    End

    Describe "sequence::_load_step_values"

        Include "./src/lib/tooling.sh"

        It "returns a step values from a sequence definition file"

            FAKE_DEFINITION_PATH="config/fake_definition.json"

            BeforeCall "tooling::set_jq"
            step_definition="""{\"id\":\"fake_id_1\",\"fake_step\":\"fake_value_1\"}"""

            # shellcheck disable=SC2154
            When call sequence::_load_step_values "${step_definition}"

            The status should be success
            The variable fake_step should eq "fake_value_1"
            The stderr should be present # for logs redirected into stderr
        End

    End

    Describe "sequence::_iterate_over_sequence"

        Include "./src/lib/tooling.sh"

        It "returns a status success when all steps are executed"

            FAKE_DEFINITION_PATH="config/fake_definition.json"

            BeforeCall "tooling::set_jq"
            BeforeCall "echo '{\"sequence\": [ \
                {\"id\": \"fake_id_1\", \"fake_step\": \"fake_value_1\"}, \
                {\"id\": \"fake_id_2\", \"fake_step\": \"fake_value_2\"} \
                ]}' > ${FAKE_DEFINITION_PATH}"
            AfterCall "rm ${FAKE_DEFINITION_PATH}"

            sequences_id=( fake_id_1 fake_id_2 )

            # shellcheck disable=SC2154
            When call sequence::_iterate_over_sequence "${FAKE_DEFINITION_PATH}" "${sequences_id[@]}"

            The status should be success
            The stderr should include "Loop over step fake_id_1"
            The stderr should include "Loop over step fake_id_2"
            The variable fake_step should eq "fake_value_2"
        End

    End

    Describe "sequence::load"
    
        Include "./src/lib/tooling.sh"

        It "returns a status success when all steps are executed"

            FAKE_DEFINITION_PATH="config/fake_definition.json"

            BeforeCall "tooling::set_jq"
            BeforeCall "echo '{\"sequence\": [ \
                {\"id\": \"fake_id_1\", \"fake_step\": \"fake_value_1\"}, \
                {\"id\": \"fake_id_2\", \"fake_step\": \"fake_value_2\"} \
                ]}' > ${FAKE_DEFINITION_PATH}"
            AfterCall "rm ${FAKE_DEFINITION_PATH}"

            # shellcheck disable=SC2154
            When call sequence::load "${FAKE_DEFINITION_PATH}"

            The status should be success
            The stderr should include "Loop over step fake_id_1"
            The stderr should include "Loop over step fake_id_2"
            The variable fake_step should eq "fake_value_2"
        End

    End

End
