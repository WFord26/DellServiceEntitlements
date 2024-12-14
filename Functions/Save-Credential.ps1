<#
.SYNOPSIS
Saves a credential object to an XML file.

.DESCRIPTION
The Save-Credential function takes a target name, username, and password, and saves the credential object to an XML file in the user's profile directory under a hidden ".dell" folder. If the folder does not exist, it will be created.

.PARAMETER target
The name of the target for which the credential is being saved. This will be used as the filename for the XML file.

.PARAMETER username
The username to be saved in the credential object.

.PARAMETER password
The password to be saved in the credential object. This should be provided as a SecureString.

.EXAMPLE
Save-Credential -target "MyService" -username "user1" -password (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force)
This example saves the credential for "user1" with the password "P@ssw0rd" to a file named "MyService.xml" in the ".dell" folder in the user's profile directory.

.NOTES
The function uses Export-Clixml to save the credential object, which ensures that the password is securely stored in the XML file.
#>
function Save-Credential {
    param (
        [string]$target,
        [string]$username,
        [SecureString]$password
    )

    # Create directory if it does not exist
    if (-Not (Test-Path "$env:USERPROFILE\.dell")) {
        New-Item -ItemType Directory -Path "$env:USERPROFILE\.dell"
    }
    # Save the credential to a file
    $credential = New-Object -TypeName PSCredential -ArgumentList $username, $password
    $credential | Export-Clixml -Path "$env:USERPROFILE\.dell\$target.xml"
}