# Define standardized paths
$BuildRoot = $PSScriptRoot
$ModuleRoot = Split-Path $BuildRoot -Parent
$ModuleManifest = Join-Path $ModuleRoot "DellServiceEntitlements.psd1"
$TestsPath = Join-Path $ModuleRoot "tests"
$BuildPath = $BuildRoot

# Import module and get command list
Import-Module -Name $ModuleManifest -Force
$commandList = Get-Command -Module DellServiceEntitlements

# Import helper functions
. (Join-Path $BuildRoot "ModuleVersionHelper.ps1")

# Test Functions first before building the fingerprint
Write-Output "Running PowerShell script tests..."
& (Join-Path $TestsPath "Test-AllPowerShellScripts.ps1") -IncludeModuleTests
$exitCode = $LASTEXITCODE
Write-Output "Test exit code: $exitCode"
if ($exitCode -ne 0) {
    Write-Error "Tests failed with exit code $exitCode"
    exit $exitCode
}

# Run Check-DocumentationMD to ensure documentation is up-to-date
Write-Output "Checking documentation..."
$docCheck = & (Join-Path $TestsPath "Check-DocumentationMD.ps1")
Write-Output "Documentation check result: $docCheck"
<#
if (-not $docCheck) {
    Write-Error "Documentation check failed. Please ensure all functions have documentation."
    exit 1
}
#>
Write-Output 'Calculating fingerprint'

# Define common parameters to exclude from fingerprinting
$commonParams = @(
    'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction',
    'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable',
    'OutBuffer', 'PipelineVariable', 'WhatIf', 'Confirm'
)

# Create an improved fingerprint that properly categorizes commands and parameters
$fingerprint = @()

foreach ($command in $commandList) {
    # Add the command itself to fingerprint
    $fingerprint += "Command:$($command.Name)"
    
    # Add each parameter (excluding common parameters)
    foreach ($parameter in $command.parameters.keys) {
        if ($parameter -in $commonParams) { continue }
        
        $fingerprint += "Param:$($command.name):$($command.parameters[$parameter].Name)"
        
        # Add parameter aliases
        $command.parameters[$parameter].aliases | 
            ForEach-Object { $fingerprint += "Alias:$($command.name):$($command.parameters[$parameter].Name):$_" }
    }
}

# Define fingerprint paths
$FingerprintPath = Join-Path $BuildPath "fingerprint"
$FingerprintBackupDir = Join-Path $BuildPath "Fingerprints"

# Get the old fingerprint if it exists
$oldFingerprint = @()
if (Test-Path $FingerprintPath) {
    $oldFingerprint = Get-Content $FingerprintPath
    # Backup the old fingerprint
    $date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $backupPath = Join-Path $FingerprintBackupDir "fingerprint$($date).bak"
    Copy-Item -Path $FingerprintPath -Destination $backupPath -Force
}

# Default to a patch version bump
$bumpVersionType = 'Patch'

# Extract commands and parameters from both fingerprints
$oldCommands = $oldFingerprint | Where-Object { $_ -like "Command:*" } | ForEach-Object { $_ -replace "Command:", "" }
$newCommands = $fingerprint | Where-Object { $_ -like "Command:*" } | ForEach-Object { $_ -replace "Command:", "" }
$oldParams = $oldFingerprint | Where-Object { $_ -like "Param:*" }
$newParams = $fingerprint | Where-Object { $_ -like "Param:*" }

# Detect breaking changes - removed commands
$removedCommands = $oldCommands | Where-Object { $_ -notin $newCommands }
if ($removedCommands) {
    $bumpVersionType = 'Major'
    Write-Output "Detected breaking changes (removed commands):"
    $removedCommands | ForEach-Object { Write-Output "  $_" }
}

# Detect breaking changes - removed parameters (only if we haven't already decided on a major bump)
if ($bumpVersionType -ne 'Major') {
    $removedParams = $oldParams | Where-Object { $_ -notin $newParams }
    
    if ($removedParams) {
        $bumpVersionType = 'Major'
        Write-Output "Detected breaking changes (removed parameters):"
        $removedParams | ForEach-Object { Write-Output "  $_" }
    }
}

# Detect new features (only if we haven't already decided on a major bump)
if ($bumpVersionType -ne 'Major') {
    $addedCommands = $newCommands | Where-Object { $_ -notin $oldCommands }
    $addedParams = $newParams | Where-Object { $_ -notin $oldParams }
    
    if ($addedCommands -or $addedParams) {
        $bumpVersionType = 'Minor'
        
        if ($addedCommands) {
            Write-Output "Detected new features (added commands):"
            $addedCommands | ForEach-Object { Write-Output "  $_" }
        }
        
        if ($addedParams) {
            Write-Output "Detected new features (added parameters):"
            $addedParams | ForEach-Object { Write-Output "  $_" }
        }
    }
}

Write-Output "Version bump type: $bumpVersionType"

# Save the new fingerprint
Set-Content -Path $FingerprintPath -Value $fingerprint

# Update the module version
Step-ModuleVersion -Path $ModuleManifest -By $bumpVersionType