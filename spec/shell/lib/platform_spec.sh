# shellcheck disable=SC2148

Describe "Test that platform.sh"

    Include "./shell/lib/platform.sh"

    Describe "_is_jenkins()"

        It "returns true when all Jenkins env variables are set"

            BeforeCall 'JENKINS_URL=FAKE_URL'
            BeforeCall 'BUILD_ID=FAKE_ID'
            BeforeCall 'WORKSPACE=FAKE_WORKSPACE'

            When call _is_jenkins
            The stdout should eq "true"
        End

        It "returns false when one Jenkins env variables is missing"

            BeforeCall 'JENKINS_URL=FAKE_URL'
            BeforeCall 'BUILD_ID=FAKE_ID'

            When call _is_jenkins
            The stdout should eq "false"
        End

        It "returns false when no Jenkins env variables are set"

            When call _is_jenkins
            The stdout should eq "false"
        End

    End

    Describe "_is_gitlab()"

        It "returns false when no Gitlab env variables are set"

            When call _is_gitlab
            The stdout should eq "false"
        End

    End

    Describe "_is_local()"

        It "returns true when no Jenkins nor Gitlab env variables are set"

            When call _is_local
            The stdout should eq "true"
        End

        It "returns false when all Jenkins env variables are set"

            BeforeCall 'JENKINS_URL=FAKE_URL'
            BeforeCall 'BUILD_ID=FAKE_ID'
            BeforeCall 'WORKSPACE=FAKE_WORKSPACE'

            When call _is_local
            The stdout should eq "false"
        End

    End

    Describe "get_platform()"

        It "returns 'JENKINS' when all Jenkins env variables are set"

            BeforeCall 'JENKINS_URL=FAKE_URL'
            BeforeCall 'BUILD_ID=FAKE_ID'
            BeforeCall 'WORKSPACE=FAKE_WORKSPACE'

            When call get_platform
            The stdout should eq "JENKINS"
        End

        It "returns 'LOCAL' when no Jenkins nor Gitlab env variables are set"

            When call get_platform
            The stdout should eq "LOCAL"
        End

    End

End