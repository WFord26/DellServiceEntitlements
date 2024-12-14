<#
.SYNOPSIS
    Retrieves an OAuth token from Dell API using client credentials.

.DESCRIPTION
    The Get-DellToken function sends a POST request to the Dell API token endpoint to retrieve an OAuth token.
    It uses the provided API key and client secret for authentication and stores the token and its expiration time in a global variable.

.PARAMETER apiKey
    The API key used for authentication.

.PARAMETER clientSecret
    The client secret used for authentication.

.EXAMPLE
    Get-DellToken

.NOTES
    Ensure that the token endpoint URL is correct and replace it if necessary.
    The token and its expiration time are stored in the global variable $Global:dellAuthToken.

#>
function Get-DellToken {
    try {
        Write-Host "Obtaining Dell token" -ForegroundColor Yellow
        $tokenUrl = "https://apigtwb2c.us.dell.com/auth/oauth/v2/token"  # Replace with your token endpoint
        $apiKey = $env:DELL_API_KEY
        $clientSecret = $env:DELL_CLIENT_SECRET

        if (-not $apiKey -or -not $clientSecret) {
            Write-Host "API key or client secret not found in environment variables." -ForegroundColor Red
            return
        }

        $authBody = @{
            "grant_type" = "client_credentials"
            "client_id" = $apiKey
            "client_secret" = $clientSecret
        }
        $getTime = Get-Date
        $authResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $authBody -ContentType "application/x-www-form-urlencoded"
        $getExpires = $getTime.AddSeconds($authResponse.expires_in)
        $dellAuthToken = @{
            "token" = $authResponse.access_token
            "expires" = $getExpires
        }
        $dellAuthToken | Export-Clixml -Path "$env:USERPROFILE\.dell\dellAuthToken.xml"
        Write-Host "Token created successfully" -ForegroundColor Green
    } catch {
        Write-Host "Error obtaining Dell token: $_" -ForegroundColor Red
        exit
    }
}