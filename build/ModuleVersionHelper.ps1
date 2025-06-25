function Step-ModuleVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet('Major', 'Minor', 'Patch')]
        [string]$By
    )
    
    if (-not (Test-Path $Path)) {
        throw "Module manifest not found at path: $Path"
    }
    
    # Read the current manifest
    $manifest = Import-PowerShellDataFile -Path $Path
    $currentVersion = [Version]$manifest.ModuleVersion
    
    # Calculate new version
    switch ($By) {
        'Major' {
            $newVersion = [Version]::new($currentVersion.Major + 1, 0, 0)
        }
        'Minor' {
            $newVersion = [Version]::new($currentVersion.Major, $currentVersion.Minor + 1, 0)
        }
        'Patch' {
            $newVersion = [Version]::new($currentVersion.Major, $currentVersion.Minor, $currentVersion.Build + 1)
        }
    }
    
    Write-Output "Updating module version from $currentVersion to $newVersion ($By bump)"
    
    # Read the manifest file content
    $manifestContent = Get-Content -Path $Path -Raw
    
    # Replace the version line
    $versionPattern = "ModuleVersion\s*=\s*['""]([^'""]+)['""]"
    $newVersionLine = "ModuleVersion = '$newVersion'"
    
    if ($manifestContent -match $versionPattern) {
        $manifestContent = $manifestContent -replace $versionPattern, $newVersionLine
        Set-Content -Path $Path -Value $manifestContent -NoNewline
        Write-Output "Successfully updated module version to $newVersion"
    }
    else {
        throw "Could not find ModuleVersion in manifest file"
    }
}
