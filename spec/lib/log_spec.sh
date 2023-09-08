# shellcheck disable=SC2148
#
# Description: Unit tests for log.sh

Describe "Test that log.sh"

    Include "./src/lib/log.sh"

    setup() {
        export WILD_CWD="${PWD}"
        export LOG_PATH="${WILD_CWD}/../tmp/log"
        export LOG_LEVEL="${LOG_LEVEL_INFO}"
    }

    BeforeAll 'setup'

    Describe "log__log"

        It "logs a message at the specified level"
            When call log__log "${LOG_LEVEL_INFO}" "Test message" "$LOG_LEVEL_INFO_COLOR" "$LOG_COLOR_OFF"
            The status should be success
            The output should eq ""
            The error should include "[INFO] Test message"
        End

        It "does not log a message at a lower level"
            When call log__log "${LOG_LEVEL_DEBUG}" "Test message" "$LOG_LEVEL_DEBUG_COLOR" "$LOG_COLOR_OFF"
            The status should be success
            The output should eq ""
            The error should not include "[INFO] Test message"
        End

    End

    Describe "log_debug"

        BeforeCall LOG_LEVEL="${LOG_LEVEL_DEBUG}"

        It "logs a message at the debug level"
            When call log_debug "Test message"
            The status should be success
            The output should eq ""
            The error should include "[DEBUG] [shellspec_evaluation_call_function] Test message"
        End

        BeforeCall LOG_LEVEL="${LOG_LEVEL_INFO}"

        It "does not log a message at a lower level"
            When call log_debug "Test message"
            The status should be success
            The output should eq ""
            The error should not include "[DEBUG] [shellspec_evaluation_call_function] Test message"
        End

    End

    Describe "log_info"

        It "logs a message at the info level"
            When call log_info "Test message"
            The status should be success
            The output should eq ""
            The error should include "[INFO] Test message"
        End

    End

    Describe "log_warn"

        It "logs a message at the warn level"
            When call log_warn "Test message"
            The status should be success
            The output should eq ""
            The error should include "[WARN] Test message"
        End

    End

    Describe "log_error"

        It "logs a message at the error level"
            When call log_error "Test message"
            The status should be success
            The output should eq ""
            The error should include "[ERROR] Test message"
        End

    End

    Describe "log_fatal"

        It "logs a message at the fatal level"
            When call log_fatal "Test message"
            The status should be success
            The output should eq ""
            The error should include "[FATAL] Test message"
        End

    End

    Describe "log_banner"

        It "logs a message as a banner"
            When call log_banner "Test message"
            The status should be success
            The output should eq ""
            The error should include "################################"
            The error should include " Test message"
        End

    End

End