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
        $env:GITHUB_OUTPUT = New-TemporaryFile
        $env:MOCK_API = $script:MockApiUrl
    }
	
    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Item Env:MOCK_API -ErrorAction SilentlyContinue
    }

	Context "Success Cases" {
	    It "unit: Test-ApproverMembership succeeds with HTTP 200" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 200; Content = '{"state": "active", "role": "member"}' }
	        }
	        Test-ApproverMembership -User $User -TeamSlug $TeamSlug -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=success"
	        $output | Should -Contain "is-member=true"
	    }	
	}

	Context "HTTP Failure Cases" {
	    It "unit: Test-ApproverMembership fails with HTTP 404" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 404; Content = '{"message":"Not Found"}' }
	        }
	        Test-ApproverMembership -User $User -TeamSlug $TeamSlug -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=success"
	        $output | Should -Contain "is-member=false"
	    }
	}

	Context "Parameter Validation Failure Cases" {
	    It "unit: Test-ApproverMembership fails with empty User" {
	        Test-ApproverMembership -User "" -TeamSlug $TeamSlug -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: user, team_slug, owner, and token must be provided."
	    }
	
	    It "unit: Test-ApproverMembership fails with empty TeamSlug" {
	        Test-ApproverMembership -User $User -TeamSlug "" -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: user, team_slug, owner, and token must be provided."
	    }
	
	    It "unit: Test-ApproverMembership fails with empty Token" {
	        Test-ApproverMembership -User $User -TeamSlug $TeamSlug -Token "" -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: user, team_slug, owner, and token must be provided."
	    }
	
	    It "unit: Test-ApproverMembership fails with empty Owner" {
	        Test-ApproverMembership -User $User -TeamSlug $TeamSlug -Token $Token -Owner ""
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: user, team_slug, owner, and token must be provided."
	    }	
	}

	Context "Exception Failure Cases" {
		It "unit: Test-ApproverMembership fails with exception" {
			Mock Invoke-WebRequest { throw "API Error" }
	
			try {
				Test-ApproverMembership -User $User -TeamSlug $TeamSlug -Token $Token -Owner $Owner
			} catch {}
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=failure"
			$output | Where-Object { $_ -match "^error-message=Error: Failed to verify approver $user is a member of the team $TeamSlug\. Exception:" } |
				Should -Not -BeNullOrEmpty
		}		
	}
}
