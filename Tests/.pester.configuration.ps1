# .pester.configuration.ps1

@{
    Run = @{
        Path = "Tests"
        Exit = $true
        Throw = $true
    }
    Output = @{
        Verbosity = "Detailed"
        CIFormat = "Auto"
    }
    CodeCoverage = @{
        Enabled = $true
        Path = ".\DellServiceEntitlements.psm1"
        OutputPath = "coverage.xml"
        CoveragePercentTarget = 80
    }
    TestResult = @{
        Enabled = $true
        OutputFormat = "NUnitXml"
        OutputPath = "test-results.xml"
    }
    Debug = @{
        ShowNavigationMarkers = $true
    }
}