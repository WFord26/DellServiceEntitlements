Import-Module Pester -Force

# Simple test to verify mock behavior
Describe "WMI Mock Test" {
    It "Should mock Get-WmiObject correctly" {
        InModuleScope DellServiceEntitlements {
            Mock Get-WmiObject { 
                Write-Host "MOCK CALLED with args: $args"
                return [PSCustomObject]@{ Manufacturer = "Dell Inc." }
            }
            
            # Test the mock directly
            $result = Get-WmiObject Win32_ComputerSystem
            Write-Host "Direct mock result: $($result | ConvertTo-Json)"
            
            # Test the pipeline
            $manufacturer = Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer
            Write-Host "Pipeline result: $manufacturer"
            
            $manufacturer | Should -Be "Dell Inc."
        }
    }
}
