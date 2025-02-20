function Test-PowerShellVersion {
    [CmdletBinding()]
    param()

    $minimumVersion = [Version]"7.0"
    $currentVersion = $PSVersionTable.PSVersion

    if ($currentVersion -lt $minimumVersion) {
        Write-Error "This module's Azure Key Vault functionality requires PowerShell 7.0 or higher. Current version: $($currentVersion.ToString())"
        Write-Error "Please upgrade PowerShell or use local credential storage instead."
        return $false
    }
    return $true
}