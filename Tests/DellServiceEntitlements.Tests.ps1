# DellServiceEntitlements.Tests.ps1

BeforeAll {
    # Import module - adjust path as needed
    $ProjectRoot = $PSScriptRoot
    $ModulePath = Join-Path -Path $ProjectRoot -ChildPath "DellServiceEntitlements.psm1"
    Import-Module -Name $ModulePath -Force

    # Mock credentials for testing
    $script:TestApiKey = "test-api-key"
    $script:TestClientSecret = "test-client-secret"
    $script:TestServiceTag = "ABC123"
    $script:TestKeyVaultName = "test-keyvault"
    
    # Mock warranty response
    $script:MockWarrantyResponse = @{
        id = "123456"
        serviceTag = "ABC123"
        orderBuid = "11"
        shipDate = "2024-01-01"
        productCode = "laptop123"
        localChannel = "45"
        productId = "latitude-5530"
        productLineDescription = "Latitude 5530"
        productFamily = "laptops"
        systemDescription = "Business Laptop"
        productLobDescription = "Latitude"
        countryCode = "US"
        duplicated = $false
        invalid = $false
        entitlements = @(
            @{
                itemNumber = "123-4567"
                startDate = "2024-01-01"
                endDate = "2025-01-01"
                entitlementType = "INITIAL"
                serviceLevelCode = "ND"
                serviceLevelDescription = "Next Business Day Support"
                serviceLevelGroup = "5"
            }
        )
    }
}

Describe "Module Installation Tests" {
    Context "Module Import" {
        It "Should import the module successfully" {
            Get-Module DellServiceEntitlements | Should -Not -BeNull
        }

        It "Should export the required functions" {
            $expectedFunctions = @(
                'Get-ServiceEntitlements',
                'Set-DellKeyVaultSecrets',
                'Get-DellKeyVaultSecrets',
                'Update-DellKeyVaultToken'
            )
            
            $exportedFunctions = Get-Command -Module DellServiceEntitlements
            foreach ($function in $expectedFunctions) {
                $exportedFunctions.Name | Should -Contain $function
            }
        }
    }
}

Describe "Local Storage Functionality Tests" {
    BeforeAll {
        # Mock the filesystem functions
        Mock Test-Path { return $false }
        Mock Export-Clixml { }
        Mock Import-Clixml { }
        Mock Get-WmiObject { 
            return @{ 
                Manufacturer = "Dell Inc."
                SerialNumber = $script:TestServiceTag
            }
        }
        
        # Mock API calls
        Mock Invoke-RestMethod { 
            if ($Uri -match "token") {
                return @{
                    access_token = "mock-token"
                    expires_in = 3600
                }
            }
            elseif ($Uri -match "asset-entitlements") {
                return $script:MockWarrantyResponse
            }
        }
    }

    Context "Get-DellApiKey Local Storage" {
        It "Should prompt for credentials when no file exists" {
            Mock Read-Host { return $script:TestApiKey }
            { Get-DellApiKey } | Should -Not -Throw
            Assert-MockCalled Read-Host -Times 1
        }

        It "Should set script-level variables" {
            Mock Read-Host { return $script:TestApiKey }
            Get-DellApiKey
            $script:userClientKey | Should -Be $script:TestApiKey
        }
    }

    Context "Get-ServiceEntitlements Local Storage" {
        It "Should retrieve warranty information for a specific service tag" {
            $result = Get-ServiceEntitlements -serviceTag $script:TestServiceTag
            $result | Should -Not -BeNull
            Assert-MockCalled Invoke-RestMethod -Times 2 # One for token, one for warranty
        }

        It "Should detect local Dell system" {
            $result = Get-ServiceEntitlements
            $result | Should -Not -BeNull
            Assert-MockCalled Get-WmiObject -Times 2 # One for manufacturer, one for serial
        }
    }
}

Describe "Azure Key Vault Functionality Tests" {
    BeforeAll {
        # Mock Azure PowerShell commands
        Mock Get-AzContext { return @{ Account = @{ Id = "test@domain.com" } } }
        Mock Connect-AzAccount { }
        Mock Get-AzKeyVault { return @{ VaultName = $script:TestKeyVaultName } }
        Mock Get-AzKeyVaultSecret { 
            return @{
                SecretValue = ConvertTo-SecureString "test-value" -AsPlainText -Force
                Name = "DellApiKey"
            }
        }
        Mock Set-AzKeyVaultSecret { }
    }

    Context "Set-DellKeyVaultSecrets" {
        It "Should store credentials in Key Vault" {
            { Set-DellKeyVaultSecrets -KeyVaultName $script:TestKeyVaultName } | Should -Not -Throw
            Assert-MockCalled Set-AzKeyVaultSecret -Times 2 # One for API key, one for client secret
        }

        It "Should verify Key Vault access" {
            Set-DellKeyVaultSecrets -KeyVaultName $script:TestKeyVaultName
            Assert-MockCalled Get-AzKeyVault -Times 1
        }
    }

    Context "Get-ServiceEntitlements with Key Vault" {
        It "Should retrieve credentials from Key Vault" {
            $result = Get-ServiceEntitlements -serviceTag $script:TestServiceTag -UseKeyVault -KeyVaultName $script:TestKeyVaultName
            $result | Should -Not -BeNull
            Assert-MockCalled Get-AzKeyVaultSecret -Times 1
        }

        It "Should handle Key Vault errors gracefully" {
            Mock Get-AzKeyVaultSecret { throw "Key Vault error" }
            { Get-ServiceEntitlements -serviceTag $script:TestServiceTag -UseKeyVault -KeyVaultName $script:TestKeyVaultName } | 
                Should -Not -Throw
        }
    }
}

Describe "CSV Processing Tests" {
    BeforeAll {
        # Create test CSV content
        $script:TestCsvContent = @"
ServiceTag
ABC123
DEF456
GHI789
"@
        $script:TestCsvPath = "TestDrive:\servicetags.csv"
        Set-Content -Path $script:TestCsvPath -Value $script:TestCsvContent

        # Mock CSV-related functions
        Mock Import-Csv {
            return @(
                @{ ServiceTag = "ABC123" }
                @{ ServiceTag = "DEF456" }
                @{ ServiceTag = "GHI789" }
            )
        }
        Mock Export-Csv { }
    }

    Context "CSV File Processing" {
        It "Should process valid CSV files" {
            { Get-ServiceEntitlements -csv -csvPath $script:TestCsvPath } | Should -Not -Throw
            Assert-MockCalled Import-Csv -Times 1
        }

        It "Should create template CSV if none exists" {
            Mock Test-Path { return $false }
            Mock New-DellTemplateCSV { }
            { Get-ServiceEntitlements -csv } | Should -Not -Throw
            Assert-MockCalled New-DellTemplateCSV -Times 1
        }

        It "Should validate CSV structure" {
            Mock Import-Csv { return @( @{ InvalidColumn = "ABC123" } ) }
            { Get-ServiceEntitlements -csv -csvPath $script:TestCsvPath } | Should -Throw
        }
    }
}

Describe "Error Handling Tests" {
    Context "API Error Handling" {
        It "Should handle API authentication errors" {
            Mock Invoke-RestMethod { throw [System.Net.WebException]::new("401 Unauthorized") }
            { Get-ServiceEntitlements -serviceTag $script:TestServiceTag } | Should -Not -Throw
        }

        It "Should handle invalid service tags" {
            $script:MockWarrantyResponse.invalid = $true
            { Get-ServiceEntitlements -serviceTag "INVALID" } | Should -Not -Throw
            $script:MockWarrantyResponse.invalid = $false
        }
    }

    Context "Key Vault Error Handling" {
        It "Should handle missing Key Vault name" {
            { Get-ServiceEntitlements -UseKeyVault } | Should -Throw
        }

        It "Should handle Key Vault access errors" {
            Mock Get-AzKeyVault { throw "Access denied" }
            { Set-DellKeyVaultSecrets -KeyVaultName $script:TestKeyVaultName } | Should -Not -Throw
        }
    }
}