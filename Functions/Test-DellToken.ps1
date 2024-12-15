<#
.SYNOPSIS
    Checks for the existence of a Dell API token and generates a new one if necessary.

.DESCRIPTION
    The Check-DellToken function checks for the existence of a credential file containing the Dell API Key and Secret.
    If the credential file does not exist, it prompts the user to enter the API Key and Secret, and saves them securely.
    If the credential file exists, it retrieves the saved credentials.
    The function then checks if a global Dell authentication token exists and if it is still valid.
    If the token does not exist or has expired, it generates a new authentication token using the provided API Key and Secret.

.PARAMETER None
    This function does not take any parameters.
.EXAMPLE
    PS C:\> Check-DellToken
    Checks for the Dell API token and generates a new one if necessary.

.NOTES
    The function relies on the presence of the Save-Credential and Import-SavedCredential functions to handle credential storage and retrieval.
    The global variable $global:dellAuthToken is used to store the authentication token and its expiration time.

#>
function Test-DellToken {
    Get-DellApiKey
    $dellAuthTokenFile = "$env:USERPROFILE\.dell\dellAuthToken.xml"
    if (-Not (Test-Path $dellAuthTokenFile)) {
        Write-Host "Token does not exist, creating new Auth Token" -ForegroundColor Orange
        $basicString = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($userClientSecret)
        $plainClientSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($basicString)
        Grant-DellToken -apiKey $userClientId -clientSecret $plainClientSecret
        } else {
            $dellAuthTokenImport = Import-Clixml -Path $dellAuthTokenFile
            if ($dellAuthTokenImport.expires -lt (Get-Date)) {
                Write-Host "Token has expired, creating new Auth Token"
                $basicString = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($userClientSecret) 
                $plainClientSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($basicString)
                Grant-DellToken -apiKey $userClientId -clientSecret $plainClientSecret
            } else {
                Write-Host "Token is still valid until: $($dellAuthTokenImport.expires)"
            }
        }
}