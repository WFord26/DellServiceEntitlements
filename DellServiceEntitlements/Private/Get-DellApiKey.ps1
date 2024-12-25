
<#
.SYNOPSIS
Retrieves Dell API credentials from a specified file or prompts the user to enter them if the file does not exist.

.DESCRIPTION
The Get-DellApiKey function checks for the existence of a credential file at the specified path. 
If the file does not exist, it prompts the user to enter their API Key and Client Secret, saves these credentials to the file, and sets the corresponding environment variables.
If the file exists, it imports the saved credentials and sets the environment variables accordingly.

.PARAMETER credentialFile
The path to the credential file where the API Key and Client Secret are stored. 
Defaults to "$env:USERPROFILE\.dell\apiCredential.xml".

.EXAMPLE
PS C:\> Get-DellApiKey
Prompts the user to enter their API Key and Client Secret if the credential file does not exist, saves the credentials, and sets the environment variables.

.EXAMPLE
PS C:\> Get-DellApiKey -credentialFile "C:\path\to\customCredentialFile.xml"
Uses the specified credential file to retrieve the API Key and Client Secret, and sets the environment variables.

.NOTES
The function relies on the presence of the 'Import-SavedCredential' function to import credentials from the specified file.
If 'Import-SavedCredential' is not available, an error is thrown.

#>
function Get-DellApiKey {
    [CmdletBinding()]
    param (
        [string]$xmlFile = "$($script:userPath)apiCredential.xml"
    )
    Write-Verbose "Checking for credential file at: $xmlFile"
    if (-Not (Test-Path $xmlFile)) {
        Write-Host "Credential file not found. Please enter your API Key and Secret."
        $userClientId = Read-Host "Enter API Key"
        $userClientSecret = Read-Host "Enter Client Secret" -AsSecureString
        Save-DellCredential -target $xmlFile -username $userClientId -password $userClientSecret
        # Set the environment variables
        $script:userClientKey = $userClientId
        $script:userClientSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($userClientSecret))
    } else {
        if (-Not (Get-Command -Name Import-SavedCredential -ErrorAction SilentlyContinue)) {
            Write-Error "The function 'Import-SavedCredential' is not defined. Please ensure it is available."
            return
        }
        $credential = Import-SavedCredential -target $xmlFile
        # Set the environment variables
        $script:userClientKey = $credential.UserName
        $script:userClientSecret = $credential.GetNetworkCredential().Password
    }
}