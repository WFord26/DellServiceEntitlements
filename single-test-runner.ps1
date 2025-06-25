Import-Module Pester -Force

try {
    $config = New-PesterConfiguration
    $config.Run.Path = "tests\DellServiceEntitlements.Tests.ps1"
    $config.Filter.Tag = @()
    $config.Filter.ExcludeTag = @()
    $config.Filter.Line = @()
    $config.Filter.FullName = "*Should detect local Dell system*"
    $config.Output.Verbosity = "Detailed"
    $config.Run.PassThru = $true
    $config.Should.ErrorAction = "Continue"
    
    $result = Invoke-Pester -Configuration $config
    
    if ($result.FailedCount -gt 0) {
        Write-Host "=== SINGLE TEST FAILURE DETAILS ===" -ForegroundColor Red
        foreach ($test in $result.Tests | Where-Object { $_.Result -eq "Failed" }) {
            Write-Host "FAILED: $($test.ExpandedName)" -ForegroundColor Red
            Write-Host "  Path: $($test.ScriptBlock.File):$($test.ScriptBlock.StartPosition.StartLine)" -ForegroundColor Red
            if ($test.ErrorRecord) {
                Write-Host "  Error: $($test.ErrorRecord.Exception.Message)" -ForegroundColor Red
                Write-Host "  Error Type: $($test.ErrorRecord.Exception.GetType().Name)" -ForegroundColor Red
                Write-Host "  Stack Trace: $($test.ErrorRecord.ScriptStackTrace)" -ForegroundColor Red
            }
            Write-Host ""
        }
    }
    
} catch {
    Write-Host "Error running test: $_" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
}
