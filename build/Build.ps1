$ModuleName = 'C:\Users\wford.MS\GitHub\DellServiceEntitlements\DellServiceEntitlements.psd1'
Import-Module -name $ModuleName -Force
$commandList = Get-Command -Module DellServiceEntitlements

# Import helper functions
. "$PSScriptRoot\ModuleVersionHelper.ps1"

# Test Functions first before building the fingerprint
Write-Output "Running PowerShell script tests..."
& "C:\Users\wford.MS\GitHub\DellServiceEntitlements\tests\Test-AllPowerShellScripts.ps1" -IncludeModuleTests
$exitCode = $LASTEXITCODE
Write-Output "Test exit code: $exitCode"
if ($exitCode -ne 0) {
    Write-Error "Tests failed with exit code $exitCode"
    exit $exitCode
}

# Run Check-DocumentationMD to ensure documentation is up-to-date
Write-Output "Checking documentation..."
$docCheck = & "C:\Users\wford.MS\GitHub\DellServiceEntitlements\tests\Check-DocumentationMD.ps1"
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

# Get the old fingerprint if it exists
$oldFingerprint = @()
if (Test-Path "C:\Users\wford.MS\GitHub\DellServiceEntitlements\Build\fingerprint") {
    $oldFingerprint = Get-Content "C:\Users\wford.MS\GitHub\DellServiceEntitlements\Build\fingerprint"
    # Backup the old fingerprint
    $date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    Copy-Item -Path "C:\Users\wford.MS\GitHub\DellServiceEntitlements\Build\fingerprint" -Destination "C:\Users\wford.MS\GitHub\DellServiceEntitlements\Build\Fingerprints\fingerprint$($date).bak" -Force
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
Set-Content -Path "C:\Users\wford.MS\GitHub\DellServiceEntitlements\Build\fingerprint" -Value $fingerprint

# Update the module version
$ManifestPath = 'C:\Users\wford.MS\GitHub\DellServiceEntitlements\DellServiceEntitlements.psd1'
Step-ModuleVersion -Path $ManifestPath -By $bumpVersionType