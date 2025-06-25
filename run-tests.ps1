Import-Module Pester -Force
$config = New-PesterConfiguration
$config.Run.Path = "tests\DellServiceEntitlements.Tests.ps1"
$config.Output.Verbosity = "Detailed"
$config.Run.PassThru = $true
$result = Invoke-Pester -Configuration $config
exit $result.FailedCount
