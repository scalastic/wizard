# shellcheck disable=SC2148
#
# Description: Unit tests for platform.sh

Describe "Test that platform.sh"

    Include "./src/lib/platform.sh"

    Describe "platform__is_jenkins()"

        It "should success when all Jenkins env variables are set"

            BeforeCall 'JENKINS_URL=FAKE_URL'
            BeforeCall 'BUILD_ID=FAKE_ID'
            BeforeCall 'WORKSPACE=FAKE_WORKSPACE'

            When call platform__is_jenkins
            The status should be success
        End

        It "returns false when one Jenkins env variables is missing"

            BeforeCall 'JENKINS_URL=FAKE_URL'
            BeforeCall 'BUILD_ID=FAKE_ID'

            When call platform__is_jenkins
            The status should be failure
            The status should eq 1
        End

        It "returns false when no Jenkins env variables are set"

            When call platform__is_jenkins
            The status should be failure
            The status should eq 1
        End

    End

    Describe "platform__is_gitlab()"

        It "returns false when no Gitlab env variables are set"

            When call platform__is_gitlab
            The status should be failure
            The status should eq 1
        End

    End

    Describe "platform__is_local()"

        It "returns true when no Jenkins nor Gitlab env variables are set"

            When call platform__is_local
            The status should be success
        End

        It "returns false when all Jenkins env variables are set"

            BeforeCall 'JENKINS_URL=FAKE_URL'
            BeforeCall 'BUILD_ID=FAKE_ID'
            BeforeCall 'WORKSPACE=FAKE_WORKSPACE'

            When call platform__is_local
            The status should be failure
            The status should eq 1
        End

    End

    Describe "platform_get_platform()"

        It "returns 'JENKINS' when all Jenkins env variables are set"

            BeforeCall 'JENKINS_URL=FAKE_URL'
            BeforeCall 'BUILD_ID=FAKE_ID'
            BeforeCall 'WORKSPACE=FAKE_WORKSPACE'

            When call platform_get_platform
            The stdout should eq "JENKINS"
        End

        It "returns 'LOCAL' when no Jenkins nor Gitlab env variables are set"

            When call platform_get_platform
            The stdout should eq "LOCAL"
        End

    End

End