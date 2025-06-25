param(
    [switch]$IncludeModuleTests
)

# Basic PowerShell script testing for DellServiceEntitlements module
Write-Output "Running PowerShell script tests..."

$ModuleRoot = Split-Path $PSScriptRoot -Parent
$TestsPath = Join-Path $ModuleRoot "Tests"
$ModulePath = $ModuleRoot
$ModuleManifestPath = Join-Path $ModulePath "DellServiceEntitlements.psd1"

# Verify module manifest exists
if (-not (Test-Path $ModuleManifestPath)) {
    Write-Error "Module manifest not found at: $ModuleManifestPath"
    exit 1
}

# Test if Pester is available
if (-not (Get-Module -ListAvailable -Name Pester)) {
    Write-Warning "Pester module not found. Installing Pester..."
    try {
        Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser -MinimumVersion 5.0
        Write-Output "✓ Pester installed successfully"
    }
    catch {
        Write-Error "Failed to install Pester: $_"
        exit 1
    }
}

# Import Pester
Import-Module Pester -Force

# Run syntax validation on all PowerShell files
Write-Output "Validating PowerShell syntax..."
$PowerShellFiles = Get-ChildItem -Path $ModulePath -Filter "*.ps1" -Recurse
$SyntaxErrors = @()

foreach ($File in $PowerShellFiles) {
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Path $File.FullName -Raw), [ref]$null)
        Write-Output "✓ $($File.Name) - Syntax OK"
    }
    catch {
        $SyntaxErrors += "✗ $($File.Name) - Syntax Error: $_"
        Write-Error "Syntax error in $($File.Name): $_"
    }
}

if ($SyntaxErrors.Count -gt 0) {
    Write-Error "Found $($SyntaxErrors.Count) syntax errors:"
    $SyntaxErrors | ForEach-Object { Write-Error $_ }
    exit 1
}

# Run module tests if requested and available
if ($IncludeModuleTests -and (Test-Path $TestsPath)) {
    Write-Output "Running module tests..."
    
    # Import the module before running tests
    Write-Output "Importing module for testing: $ModuleManifestPath"
    try {
        # Remove any existing module first
        Remove-Module DellServiceEntitlements -Force -ErrorAction SilentlyContinue
        Import-Module -Name $ModuleManifestPath -Force
        Write-Output "✓ Module imported successfully"
        
        # Verify module commands are available
        $exportedCommands = Get-Command -Module DellServiceEntitlements
        Write-Output "✓ Found $($exportedCommands.Count) exported commands: $($exportedCommands.Name -join ', ')"
    }
    catch {
        Write-Error "Failed to import module: $_"
        exit 1
    }
    
    $TestFiles = Get-ChildItem -Path $TestsPath -Filter "*.Tests.ps1"
    
    if ($TestFiles.Count -gt 0) {
        Write-Output "Running Pester tests..."
        
        # Configure Pester for better output (Pester v5 syntax)
        $PesterConfiguration = New-PesterConfiguration
        $PesterConfiguration.Run.Path = $TestsPath
        $PesterConfiguration.Run.PassThru = $true
        $PesterConfiguration.Output.Verbosity = 'Detailed'
        
        $TestResult = Invoke-Pester -Configuration $PesterConfiguration
        
        if ($TestResult.FailedCount -gt 0) {
            Write-Host ""
            Write-Host "Test Summary:" -ForegroundColor Yellow
            Write-Host "  Total Tests: $($TestResult.TotalCount)" -ForegroundColor White
            Write-Host "  Passed: $($TestResult.PassedCount)" -ForegroundColor Green
            Write-Host "  Failed: $($TestResult.FailedCount)" -ForegroundColor Red
            Write-Host "  Skipped: $($TestResult.SkippedCount)" -ForegroundColor Yellow
            Write-Host ""
            
            Write-Error "Tests failed: $($TestResult.FailedCount) failed, $($TestResult.PassedCount) passed"
            exit 1
        }
        else {
            Write-Host ""
            Write-Host "✓ All tests passed: $($TestResult.PassedCount) passed" -ForegroundColor Green
            Write-Host ""
        }
    }
    else {
        Write-Output "No test files found in $TestsPath"
    }
}

Write-Output "All PowerShell script tests completed successfully"
exit 0
