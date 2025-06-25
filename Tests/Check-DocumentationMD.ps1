#Requires -Version 5.1

<#
.SYNOPSIS
    Checks documentation status for all exported functions in the DellServiceEntitlements module.

.DESCRIPTION
    This script analyzes the DellServiceEntitlements module manifest (DellServiceEntitlements.psd1) to identify
    all exported functions and checks for corresponding documentation files in the Documentation
    folder. Provides a terminal-style checklist showing documentation status.

.PARAMETER ModulePath
    Path to the DellServiceEntitlements module directory. Defaults to the parent directory of this script.

.PARAMETER DocumentationPath
    Path to the Documentation folder. Defaults to Documentation subfolder in module directory.

.PARAMETER ShowMissing
    Show only functions that are missing documentation.

.PARAMETER ShowExisting
    Show only functions that have documentation.

.EXAMPLE
    .\Check-DocumentationMD.ps1
    Checks all exported functions and shows documentation status.

.EXAMPLE
    .\Check-DocumentationMD.ps1 -ShowMissing
    Shows only functions missing documentation.

.NOTES
    Author: William Ford
    Version: 1.0
    Last Updated: June 2025
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]$ModulePath = (Split-Path $PSScriptRoot -Parent),
    
    [Parameter()]
    [string]$DocumentationPath = (Join-Path (Split-Path $PSScriptRoot -Parent) "docs"),
    
    [Parameter()]
    [switch]$ShowMissing,
    
    [Parameter()]
    [switch]$ShowExisting
)

function Write-Header {
    param([string]$Title)
    Write-Host "`n" -NoNewline
    Write-Host $("=" * 80) -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor White -NoNewline
    Write-Host $(" " * (79 - $Title.Length)) -NoNewline
    Write-Host "=" -ForegroundColor Cyan
    Write-Host $("=" * 80) -ForegroundColor Cyan
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host "`n" -NoNewline
    Write-Host $("─" * 80) -ForegroundColor Gray
    Write-Host " $Title" -ForegroundColor Yellow
    Write-Host $("─" * 80) -ForegroundColor Gray
}

function Get-ExportedFunctions {
    param([string]$ManifestPath)
    
    try {
        $manifest = Import-PowerShellDataFile -Path $ManifestPath -ErrorAction Stop
        return $manifest.FunctionsToExport | Sort-Object
    }
    catch {
        Write-Error "Failed to read module manifest: $_"
        return @()
    }
}

function Test-DocumentationExists {
    param(
        [string]$FunctionName,
        [string]$DocumentationPath
    )
    
    $docFile = Join-Path $DocumentationPath "$FunctionName.md"
    return Test-Path $docFile
}

function Get-DocumentationStats {
    param(
        [array]$Functions,
        [string]$DocumentationPath
    )
    
    $results = @()
    $documented = 0
    $missing = 0
    
    foreach ($function in $Functions) {
        $hasDoc = Test-DocumentationExists -FunctionName $function -DocumentationPath $DocumentationPath
        
        $results += [PSCustomObject]@{
            FunctionName = $function
            HasDocumentation = $hasDoc
            DocumentationFile = "$function.md"
            Status = if ($hasDoc) { "✅ Documented" } else { "❌ Missing" }
        }
        
        if ($hasDoc) { $documented++ } else { $missing++ }
    }
    
    return @{
        Results = $results
        Documented = $documented
        Missing = $missing
        Total = $Functions.Count
        CompletionPercentage = if ($Functions.Count -gt 0) { [math]::Round(($documented / $Functions.Count) * 100, 1) } else { 0 }
    }
}

function Show-DocumentationChecklist {
    param(
        [array]$Results,
        [switch]$ShowMissing,
        [switch]$ShowExisting
    )
    
    foreach ($result in $Results) {
        $shouldShow = $true
        
        if ($ShowMissing -and $result.HasDocumentation) {
            $shouldShow = $false
        }
        if ($ShowExisting -and -not $result.HasDocumentation) {
            $shouldShow = $false
        }
        
        if ($shouldShow) {
            $status = if ($result.HasDocumentation) { 
                Write-Host "✅" -ForegroundColor Green -NoNewline
            } else { 
                Write-Host "❌" -ForegroundColor Red -NoNewline
            }
            
            $color = if ($result.HasDocumentation) { "Green" } else { "Red" }
            Write-Host " $($result.FunctionName)" -ForegroundColor $color -NoNewline
            Write-Host " → $($result.DocumentationFile)" -ForegroundColor Gray
        }
    }
}

function Show-Summary {
    param([hashtable]$Stats)
    
    Write-SectionHeader "Documentation Summary"
    
    Write-Host "Total Functions: " -NoNewline -ForegroundColor White
    Write-Host $Stats.Total -ForegroundColor Cyan
    
    Write-Host "Documented: " -NoNewline -ForegroundColor White
    Write-Host $Stats.Documented -ForegroundColor Green -NoNewline
    Write-Host " ($($Stats.CompletionPercentage)%)" -ForegroundColor Yellow
    
    Write-Host "Missing Documentation: " -NoNewline -ForegroundColor White
    Write-Host $Stats.Missing -ForegroundColor Red
    
    # Progress bar
    $barLength = 50
    $completed = [math]::Floor(($Stats.Documented / $Stats.Total) * $barLength)
    $remaining = $barLength - $completed
    
    Write-Host "`nProgress: [" -NoNewline -ForegroundColor White
    Write-Host ("█" * $completed) -NoNewline -ForegroundColor Green
    Write-Host ("░" * $remaining) -NoNewline -ForegroundColor DarkGray
    Write-Host "] $($Stats.CompletionPercentage)%" -ForegroundColor White
}

function Show-MissingFunctionsList {
    param([array]$Results)
    
    $missingFunctions = $Results | Where-Object { -not $_.HasDocumentation }
    
    if ($missingFunctions.Count -gt 0) {
        Write-SectionHeader "Functions Missing Documentation"
        
        foreach ($func in $missingFunctions) {
            Write-Host "• " -NoNewline -ForegroundColor Red
            Write-Host $func.FunctionName -ForegroundColor Yellow
        }
        
        Write-Host "`nTo create documentation for missing functions:" -ForegroundColor Cyan
        Write-Host "1. Create markdown files in the Documentation folder" -ForegroundColor Gray
        Write-Host "2. Use the naming convention: FunctionName.md" -ForegroundColor Gray
        Write-Host "3. Include standard sections: SYNOPSIS, SYNTAX, DESCRIPTION, etc." -ForegroundColor Gray
    }
}

function Validate-Paths {
    param(
        [string]$ModulePath,
        [string]$DocumentationPath
    )
    
    $manifestPath = Join-Path $ModulePath "DellServiceEntitlements.psd1"
    
    if (-not (Test-Path $manifestPath)) {
        Write-Error "Module manifest not found at: $manifestPath"
        return $false
    }
    
    if (-not (Test-Path $DocumentationPath)) {
        Write-Warning "Documentation folder not found at: $DocumentationPath"
        Write-Host "Creating Documentation folder..." -ForegroundColor Yellow
        try {
            New-Item -Path $DocumentationPath -ItemType Directory -Force | Out-Null
            Write-Host "Documentation folder created successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to create Documentation folder: $_"
            return $false
        }
    }
    
    return $true
}

# Main script execution
try {
    Write-Header "DellServiceEntitlements Module - Documentation Status Check"
    
    # Validate paths
    if (-not (Validate-Paths -ModulePath $ModulePath -DocumentationPath $DocumentationPath)) {
        exit 1
    }
    
    $manifestPath = Join-Path $ModulePath "DellServiceEntitlements.psd1"
    
    Write-Host "Module Path: " -NoNewline -ForegroundColor White
    Write-Host $ModulePath -ForegroundColor Cyan
    
    Write-Host "Documentation Path: " -NoNewline -ForegroundColor White
    Write-Host $DocumentationPath -ForegroundColor Cyan
    
    Write-Host "Manifest Path: " -NoNewline -ForegroundColor White
    Write-Host $manifestPath -ForegroundColor Cyan
    
    # Get exported functions
    Write-Host "`nReading module manifest..." -ForegroundColor Yellow
    $exportedFunctions = Get-ExportedFunctions -ManifestPath $manifestPath
    
    if ($exportedFunctions.Count -eq 0) {
        Write-Warning "No exported functions found in the module manifest."
        exit 1
    }
    
    Write-Host "Found $($exportedFunctions.Count) exported functions." -ForegroundColor Green
    
    # Check documentation status
    Write-Host "Checking documentation status..." -ForegroundColor Yellow
    $stats = Get-DocumentationStats -Functions $exportedFunctions -DocumentationPath $DocumentationPath
    
    # Show results
    Write-SectionHeader "Documentation Status Checklist"
    Show-DocumentationChecklist -Results $stats.Results -ShowMissing:$ShowMissing -ShowExisting:$ShowExisting
    
    # Show summary
    Show-Summary -Stats $stats
    
    # Show missing functions if any
    if ($stats.Missing -gt 0 -and -not $ShowExisting) {
        Show-MissingFunctionsList -Results $stats.Results
    }
    
    # Final status
    Write-Host "`n" -NoNewline
    if ($stats.Missing -eq 0) {
        Write-Host "🎉 All functions are documented!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "⚠️  Documentation incomplete. $($stats.Missing) function(s) need documentation." -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Error "Script execution failed: $_"
    Write-Host "Stack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
    exit 1
}