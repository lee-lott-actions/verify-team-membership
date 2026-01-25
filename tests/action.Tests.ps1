Describe "Test-ApproverMembership" {
    BeforeAll {
        $script:User      = "test-user"
        $script:TeamSlug  = "test-team"
        $script:Token     = "fake-token"
        $script:Owner     = "test-owner"
        $script:MockApiUrl= "http://127.0.0.1:3000"
        . "$PSScriptRoot/../action.ps1"
    }
    BeforeEach {
        $env:GITHUB_OUTPUT = "$PSScriptRoot/github_output.temp"
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        $env:MOCK_API = $script:MockApiUrl
    }
    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Variable -Name MOCK_API -Scope Global -ErrorAction SilentlyContinue
    }

    It "check_approver_membership succeeds with HTTP 200" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{ StatusCode = 200; Content = '{"state": "active", "role": "member"}' }
        }
        Test-ApproverMembership -User $User -TeamSlug $TeamSlug -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=success"
        $output | Should -Contain "is-member=true"
    }

    It "check_approver_membership fails with HTTP 404 (not a member)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{ StatusCode = 404; Content = '{"message":"Not Found"}' }
        }
        Test-ApproverMembership -User $User -TeamSlug $TeamSlug -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=success"
        $output | Should -Contain "is-member=false"
    }

    It "check_approver_membership fails with empty user" {
        Test-ApproverMembership -User "" -TeamSlug $TeamSlug -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: user, team_slug, owner, and token must be provided."
    }

    It "check_approver_membership fails with empty team_slug" {
        Test-ApproverMembership -User $User -TeamSlug "" -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: user, team_slug, owner, and token must be provided."
    }

    It "check_approver_membership fails with empty token" {
        Test-ApproverMembership -User $User -TeamSlug $TeamSlug -Token "" -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: user, team_slug, owner, and token must be provided."
    }

    It "check_approver_membership fails with empty owner" {
        Test-ApproverMembership -User $User -TeamSlug $TeamSlug -Token $Token -Owner ""
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: user, team_slug, owner, and token must be provided."
    }
}