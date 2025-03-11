# Get-ServiceEntitlements.ps1
<#PSScriptInfo

.VERSION 0.3.0

.GUID ce5906a5-7211-4f45-bd49-7e0691741347

.AUTHOR wford@managedsolution.com

.COMPANYNAME Managed Solution

.COPYRIGHT

.TAGS Dell, Warranty, Service Tag, Serial Number, Azure Key Vault

.LICENSEURI https://github.com/WFord26/DellServiceEntitlements/blob/master/LICENSE

.PROJECTURI https://github.com/WFord26/DellServiceEntitlements

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Added Azure Key Vault support for credential storage and management
#>

<# 
.DESCRIPTION 
The Get-ServiceEntitlements function retrieves the serial number of a Dell computer and fetches its warranty information. 
It can also process a CSV file containing multiple service tags and fetch warranty information for each.
Supports both local credential storage and Azure Key Vault integration.

.SYNOPSIS
Retrieves the serial number and warranty information for Dell computers.

.PARAMETER csv
A switch parameter to indicate that a CSV file containing service tags will be processed. If set to $true, the csvPath parameter is required.

.PARAMETER csvPath
The file path to the CSV file containing service tags. This parameter is required if the csv parameter is set to $true.

.PARAMETER serviceTag
The service tag of the Dell computer. If not provided, the function will attempt to retrieve the service tag from the local machine.

.PARAMETER UseKeyVault
A switch parameter to indicate that Azure Key Vault should be used for credential storage and token management.

.PARAMETER KeyVaultName
The name of the Azure Key Vault where Dell API credentials are stored. Required if UseKeyVault is specified.

.PARAMETER ApiKeySecretName
Optional. The name of the secret in Key Vault that stores the Dell API Key. Defaults to "DellApiKey".

.PARAMETER ClientSecretName
Optional. The name of the secret in Key Vault that stores the Dell Client Secret. Defaults to "DellClientSecret".

.PARAMETER AuthTokenSecretName
Optional. The name of the secret in Key Vault that stores the Dell Auth Token. Defaults to "DellAuthToken".

.EXAMPLE
Get-ServiceEntitlements -csv -csvPath "C:\path\to\file.csv" -UseKeyVault -KeyVaultName "MyKeyVault"
Fetches warranty information for each service tag listed in the specified CSV file using Azure Key Vault credentials.

.EXAMPLE
Get-ServiceEntitlements -serviceTag "ABC1234" -UseKeyVault -KeyVaultName "MyKeyVault"
Fetches warranty information for the specified service tag using Azure Key Vault credentials.

.EXAMPLE
Get-ServiceEntitlements
Fetches the serial number and warranty information for the local Dell computer using local credential storage.
#>
function Get-ServiceEntitlements {
    [CmdletBinding()]
    param (
        [switch]$csv,
        [switch]$passThrough,
        [string]$csvPath,
        [string]$serviceTag,
        [switch]$UseKeyVault,
        [string]$KeyVaultName,
        [string]$ApiKeySecretName = "DellApiKey",
        [string]$ClientSecretName = "DellClientSecret",
        [string]$AuthTokenSecretName = "DellAuthToken"
    )

    # Validate Key Vault parameters if UseKeyVault is specified
    if ($UseKeyVault -and -not $KeyVaultName) {
        Write-Error "KeyVaultName is required when using Azure Key Vault"
        return
    }

    # Set the users profile path based on the OS
    Set-UserProfilePath

    # Check if Token exists if it does not or has expired, create a new one
    if ($UseKeyVault) {
        Test-DellToken -UseKeyVault -KeyVaultName $KeyVaultName -AuthTokenSecretName $AuthTokenSecretName
    } else {
        Test-DellToken
    }

    if ($csv) {
        # Check if a CSV file path was provided, if not set a default value.
        if (-not $csvPath) {
            $csvPath = "Not Provided"
        }

        # Check if UNIX or Windows path
        if ($env:OS -eq "Windows_NT") {
            $logPath = "$($env:USERPROFILE)\"
        } else {
            $logPath = "$($env:HOME)/"
        }

        # Test the CSV file exists and to ensure that it contains a ServiceTag column
        Test-ServiceTagCSV -Path $csvPath

        # Get the current date and time for logging purposes
        $currentDateTime = Get-Date -Format "yyyy-MM-dd-HH.mm.ss"

        # Initialize the array to hold warranty line items
        $warrantyLineItems = @()

        # loop through each row in the CSV file and fetch warranty information
        foreach ($row in $script:csvContent) {
            $csvServiceTag = $row.ServiceTag
            Write-Verbose "Processing service tag: $csvServiceTag"
            
            if ($UseKeyVault) {
                Get-DellWarranty -serviceTag $csvServiceTag -UseKeyVault -KeyVaultName $KeyVaultName
            } else {
                Get-DellWarranty -serviceTag $csvServiceTag
            }

            if ($script:warranty.invalid -eq $true) {
                Write-Host "Invalid service tag: $csvServiceTag" -ForegroundColor Red
                continue
            } else {
                # Count the number of entitlements
                $entitlements = @()
                $entitlementCount = $script:warranty.entitlements.Count - 1
                $i = 0

                # Break out the Entitlements array into separate lines
                while ($i -le $entitlementCount) {
                    $entitlement = "Start Date: $($script:warranty.entitlements[$i].startDate), End Date: $($script:warranty.entitlements[$i].endDate), Service Level: $($script:warranty.entitlements[$i].serviceLevelDescription), Warranty Type: $($script:warranty.entitlements[$i].serviceLevelCode) `n"
                    $entitlements += $entitlement
                    $i++
                }

                # Create a custom object with the warranty information
                $warrantyLineItem = @{
                    "ServiceTag" = $csvServiceTag
                    "ID" = $script:warranty.id
                    "Country" = $script:warranty.countryCode
                    "Product" = $script:warranty.productLobDescription
                    "System Type" = $script:warranty.systemDescription
                    "Start Date" = $script:warranty.shipDate
                    "Entitlements" = $entitlements | Out-String
                }
            }
            # Add the warranty information to an array
            $warrantyLineItems += New-Object PSObject -Property $warrantyLineItem
        }

        # Export the warranty information to a CSV file
        $warrantyLineItems | Export-Csv -Path "$($logPath)DellWarranty-$($currentDateTime).csv" -Append -NoTypeInformation
        Write-Host "Warranty information for service tags exported to: $($logPath)DellWarranty-$($currentDateTime).csv" -ForegroundColor Green

        # Clear the warranty object
        $script:warranty = $null

    } elseif (-not $serviceTag) {
        # If no service tag is provided, attempt to retrieve from local machine
        if (-not ((Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer) -eq "Dell Inc.")) {
            Write-Host "This script is only for Dell computers"
            Exit
        }
        Write-Host "Service Tag not provided, attempting to retrieve from local machine"
        $serialNumber = Get-WmiObject Win32_BIOS | Select-Object -ExpandProperty SerialNumber
        
        if ($UseKeyVault) {
            Get-DellWarranty -serviceTag $serialNumber -UseKeyVault -KeyVaultName $KeyVaultName
        } else {
            Get-DellWarranty -serviceTag $serialNumber
        }

        if ($script:warranty.invalid -eq $true) {
            Write-Host "Incorrect service tag provided. Please provide a valid service tag." -ForegroundColor Red
        } else {
            if ($passThrough){
                return $script:warranty
            } else {
                # Break out the entitlements output
                $entitlements = @()
                $entitlementCount = $script:warranty.entitlements.Count - 1
                $i = 0
                
                while ($i -le $entitlementCount) {
                    $entitlement = @{
                        'Start Date' = $script:warranty.entitlements[$i].startDate
                        'End Date' = $script:warranty.entitlements[$i].endDate
                        'Service Level' = $script:warranty.entitlements[$i].serviceLevelDescription
                        'Warranty Type' = $script:warranty.entitlements[$i].entitlementType
                    }
                    $entitlements += "-------- Entitlement ($($i + 1)) --------"
                    $entitlements += $entitlement
                    $i++
                }

                # Create a custom object with the warranty information
                $warrantyInfo = @{
                    "ServiceTag" = $script:warranty.serviceTag
                    "ID" = $script:warranty.id
                    "Country" = $script:warranty.countryCode
                    "Product" = $script:warranty.productLobDescription
                    "System Type" = $script:warranty.systemDescription
                    "Start Date" = $script:warranty.shipDate
                }

                # Output the warranty information
                $warrantyInfo
                $i=0
                foreach ($entitlement in $entitlements){
                    $i++
                    Write-Host "-------- Entitlement ($($i)) --------" -ForegroundColor Green
                    $entitlement
                }
            }
           
        }
    } else {
        Write-Host "Service Tag provided, fetching warranty information"
        
        if ($UseKeyVault) {
            Get-DellWarranty -serviceTag $serviceTag -UseKeyVault -KeyVaultName $KeyVaultName
        } else {
            Get-DellWarranty -serviceTag $serviceTag
        }

        if ($script:warranty.invalid -eq $true) {
            Write-Host "Incorrect service tag provided. Please provide a valid service tag." -ForegroundColor Red
        } else {
            if ($passThrough){
                return $script:warranty
            } else {
                # Break out the entitlements output
                $entitlements = @()
                $entitlementCount = $script:warranty.entitlements.Count - 1
                $i = 0
                
                while ($i -le $entitlementCount) {
                    $entitlement = @{
                        'Start Date' = $script:warranty.entitlements[$i].startDate
                        'End Date' = $script:warranty.entitlements[$i].endDate
                        'Service Level' = $script:warranty.entitlements[$i].serviceLevelDescription
                        'Warranty Type' = $script:warranty.entitlements[$i].entitlementType
                    }
                    $entitlements += $entitlement
                    $i++
                }

                # Create a custom object with the warranty information
                $warrantyInfo = @{
                    "ServiceTag" = $script:warranty.serviceTag
                    "ID" = $script:warranty.id
                    "Country" = $script:warranty.countryCode
                    "Product" = $script:warranty.productLobDescription
                    "System Type" = $script:warranty.systemDescription
                    "Start Date" = $script:warranty.shipDate
                }

                # Output the warranty information
                $warrantyInfo
                $i=0
                foreach ($entitlement in $entitlements){
                    $i++
                    Write-Host "-------- Entitlement ($($i)) --------" -ForegroundColor Green
                    $entitlement
                }
            }
        }
    }
}