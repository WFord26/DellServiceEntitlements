<#
.SYNOPSIS
Retrieves a saved credential from an XML file.

.DESCRIPTION
The Get-SavedCredential function imports a credential object from an XML file located in the user's profile directory under the .dell folder. The XML file is specified by the target parameter.

.PARAMETER target
The name of the XML file (without extension) that contains the saved credential.

.RETURNS
PSCredential
The function returns a PSCredential object that contains the saved credential.

.EXAMPLE
PS C:\> $cred = Get-SavedCredential -target "MyCredential"
This command retrieves the credential stored in MyCredential.xml and assigns it to the $cred variable.

.NOTES
The XML file must be located in the .dell folder within the user's profile directory.
#>
function Get-SavedCredential {
    param (
        [string]$target
    )
    $credential = Import-Clixml -Path "$env:USERPROFILE\.dell\$target.xml"
    return $credential
}