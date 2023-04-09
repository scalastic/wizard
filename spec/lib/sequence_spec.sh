# shellcheck disable=SC2148

Describe "Test that sequence.sh"

    Include "./lib/log.sh"

    setup() { 
        export LOG_LEVEL="${LOG_LEVEL_INFO}"
        export WILD_CWD="${PWD}"
    }
    BeforeAll 'setup'

    Include "./lib/sequence.sh"

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

        Include "./lib/tooling.sh"

        It "returns a sequence of ids from a sequence definition file"

            FAKE_DEFINITION_PATH="config/fake_definition.json"

            BeforeRun "set_jq_tool"
            BeforeRun "echo '{\"sequence\": [{\"id\": \"fake_id_1\"}, {\"id\": \"fake_id_2\"}]}' > ${FAKE_DEFINITION_PATH}"
            AfterRun "rm ${FAKE_DEFINITION_PATH}"

            When run sequence::_load_sequences_id "${FAKE_DEFINITION_PATH}"

            The status should be success
            The output should eq "fake_id_1 fake_id_2"
            The stderr should be present # for logs redirected into stderr
        End

    End

End