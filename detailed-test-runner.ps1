Import-Module Pester -Force

try {
    $config = New-PesterConfiguration
    $config.Run.Path = "tests\DellServiceEntitlements.Tests.ps1"
    $config.Output.Verbosity = "Detailed"
    $config.Run.PassThru = $true
    $config.Should.ErrorAction = "Continue"
    
    $result = Invoke-Pester -Configuration $config
    
    Write-Host ""
    Write-Host "=== DETAILED TEST RESULTS ===" -ForegroundColor Yellow
    Write-Host "Total Tests: $($result.TotalCount)" -ForegroundColor White
    Write-Host "Passed: $($result.PassedCount)" -ForegroundColor Green
    Write-Host "Failed: $($result.FailedCount)" -ForegroundColor Red
    Write-Host "Skipped: $($result.SkippedCount)" -ForegroundColor Yellow
    Write-Host ""
    
    if ($result.FailedCount -gt 0) {
        Write-Host "=== FAILED TESTS ===" -ForegroundColor Red
        foreach ($test in $result.Tests | Where-Object { $_.Result -eq "Failed" }) {
            Write-Host "FAILED: $($test.ExpandedName)" -ForegroundColor Red
            Write-Host "  Error: $($test.ErrorRecord)" -ForegroundColor Red
            Write-Host ""
        }
    }
    
    exit $result.FailedCount
} catch {
    Write-Host "Error running tests: $_" -ForegroundColor Red
    exit 1
}
