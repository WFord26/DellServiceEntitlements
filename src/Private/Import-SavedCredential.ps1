<#
.SYNOPSIS
Retrieves a saved credential from an XML file.

.DESCRIPTION
The Import-SavedCredential function imports a credential object from an XML file located in the user's profile directory under the .dell folder. The XML file is specified by the target parameter.

.PARAMETER target
The name of the XML file (without extension) that contains the saved credential.

.RETURNS
PSCredential
The function returns a PSCredential object that contains the saved credential.

.EXAMPLE
PS C:\> $cred = Import-SavedCredential -target "MyCredential"
This command retrieves the credential stored in MyCredential.xml and assigns it to the $cred variable.

.NOTES
The XML file must be located in the .dell folder within the user's profile directory.
#>
function Import-SavedCredential {
    param (
        [string]$target
    )
    # Check if target is provided
    if (-not $target) {
        Write-Host "Target name is required to call Import-SavedCredential." -ForegroundColor Red
        return
    }
    # Check if the file exists
    if (-not (Test-Path $target)) {
        Write-Host "Credential file not found at path: $target" -ForegroundColor Red
        Get-DellApiKey
        return
    }
    $credential = Import-Clixml -Path $target
    return $credential
}