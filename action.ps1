function Test-ApproverMembership {
    param(
        [string]$User,
        [string]$TeamSlug,
        [string]$Token,
        [string]$Owner
    )

    # Validate required inputs
    if ([string]::IsNullOrEmpty($User) -or
        [string]::IsNullOrEmpty($TeamSlug) -or
        [string]::IsNullOrEmpty($Owner) -or
        [string]::IsNullOrEmpty($Token)) {
        Write-Output "Error: Missing required parameters"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Missing required parameters: user, team_slug, owner, and token must be provided."
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        return
    }

    # Use MOCK_API if set, otherwise default to GitHub API
    $apiBaseUrl = $env:MOCK_API
    if (-not $apiBaseUrl) { $apiBaseUrl = "https://api.github.com" }
    $uri = "$apiBaseUrl/orgs/$Owner/teams/$TeamSlug/memberships/$User"

    $headers = @{
        Authorization  = "Bearer $Token"
        Accept         = "application/vnd.github.v3+json"
        "Content-Type" = "application/json"
        "User-Agent"   = "pwsh-action"
    }

    try {
        Write-Host "Sending GET request to $uri"
        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Get

        Write-Host "API Response Code: $($response.StatusCode)"
        Write-Host $response.Content

        if ($response.StatusCode -eq 200) {
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "is-member=true"
            Write-Host "User '$User' is a member of the '$TeamSlug' team."
        } else {
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "is-member=false"
            Write-Host "User '$User' is not a member of the '$TeamSlug' team."
        }
    } catch {
        $httpStatus = $_.Exception.Response.StatusCode.value__
        Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=API call failed with HTTP Status: $httpStatus"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        Write-Host "Error: API call failed with HTTP Status: $httpStatus"
    }
}