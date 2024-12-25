<#
.SYNOPSIS
    Tests the validity of the Dell API authentication token and generates a new one if necessary.

.DESCRIPTION
    The Test-DellToken function checks if the Dell API authentication token exists and is valid. 
    If the token does not exist or has expired, it generates a new authentication token using stored credentials.

.PARAMETER None
    This function does not take any parameters.

.EXAMPLE
    PS C:\> Test-DellToken
    Checks the Dell API authentication token and generates a new one if necessary.

.NOTES
    The function relies on the presence of the Get-DellApiKey, Grant-DellToken, and Import-SavedCredential functions.
    The authentication token is stored in an XML file located at "$env:USERPROFILE\.dell\dellAuthToken.xml".
    The credentials for generating a new token are stored in an XML file located at "$env:USERPROFILE\.dell\apiCredential.xml".

#>

function Test-DellToken {
    Get-DellApiKey
    $dellAuthTokenFile = "$($script:userPath)AuthToken.xml"
    if (-Not (Test-Path $dellAuthTokenFile)) {
        Write-Host "Token does not exist, creating new Auth Token" -ForegroundColor Yellow
        Get-DellApiKey
        Grant-DellToken 
    } else {
            $dellAuthTokenImport = Import-Clixml -Path $dellAuthTokenFile
            if ($dellAuthTokenImport.expires -lt (Get-Date)) {
                Write-Host "Token has expired, creating new Auth Token"
                $credential = Import-SavedCredential -target "$env:USERPATH"
                $script:userClientKey= $credential.UserName
                $script:userClientSecret = $credential.GetNetworkCredential().Password
                Grant-DellToken
            } 
    }
}