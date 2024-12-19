<#
.SYNOPSIS
Saves a credential object to an XML file.

.DESCRIPTION
The Save-DellCredential function takes a target name, username, and password, and saves the credential object to an XML file in the user's profile directory under a hidden ".dell" folder. If the folder does not exist, it will be created.

.PARAMETER target
The name of the target for which the credential is being saved. This will be used as the filename for the XML file.

.PARAMETER username
The username to be saved in the credential object.

.PARAMETER password
The password to be saved in the credential object. This should be provided as a SecureString.

.EXAMPLE
Save-DellCredential -target "MyService" -username "user1" -password (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force)
This example saves the credential for "user1" with the password "P@ssw0rd" to a file named "MyService.xml" in the ".dell" folder in the user's profile directory.

.NOTES
The function uses Export-Clixml to save the credential object, which ensures that the password is securely stored in the XML file.
#>
function Save-DellCredential {
    param (
        [string]$target,
        [string]$username,
        [SecureString]$password
    )
    # Check if target is provided
    if (-not $target) {
        Write-Host "Target name is required." -ForegroundColor Red
        return
    }
    # Breakdown the Target name removing the end \filename.xml
    $targetPath = $target -replace "\.xml", ""
    # Create directory if it does not exist
    if (-Not (Test-Path $targetPath)) {
        New-Item -ItemType Directory -Path $targetPath
    }
    # Save the credential to a file
    $credential = New-Object -TypeName PSCredential -ArgumentList $username, $password
    $credential | Export-Clixml -Path $target
}