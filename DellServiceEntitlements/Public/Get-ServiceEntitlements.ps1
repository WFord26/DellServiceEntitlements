
<#PSScriptInfo

.VERSION 0.2.0

.GUID ce5906a5-7211-4f45-bd49-7e0691741347

.AUTHOR wford@managedsolution.com

.COMPANYNAME Managed Solution

.COPYRIGHT

.TAGS Dell, Warranty, Service Tag, Serial Number

.LICENSEURI https://github.com/WFord26/DellServiceEntitlements/blob/master/LICENSE

.PROJECTURI https://github.com/WFord26/DellServiceEntitlements

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<# 

.DESCRIPTION 
The Get-ServiceEntitlements function retrieves the serial number of a Dell computer and fetches its warranty information. 
It can also process a CSV file containing multiple service tags and fetch warranty information for each.

.SYNOPSIS
Retrieves the serial number and warranty information for Dell computers.

.PARAMETER csv
A switch parameter to indicate that a CSV file containing service tags will be processed. If set to $true, the csvPath parameter is required.

.PARAMETER csvPath
The file path to the CSV file containing service tags. This parameter is required if the csv parameter is set to $true.

.PARAMETER serviceTag
The service tag of the Dell computer. If not provided, the function will attempt to retrieve the service tag from the local machine.

.EXAMPLE
Get-ServiceEntitlements -csv -csvPath "C:\path\to\file.csv"
Fetches warranty information for each service tag listed in the specified CSV file.

.EXAMPLE
Get-ServiceEntitlements -serviceTag "ABC1234"
Fetches warranty information for the specified service tag.

.EXAMPLE
Get-ServiceEntitlements
Fetches the serial number and warranty information for the local Dell computer.
#>
function Get-ServiceEntitlements{
    [CmdletBinding()]
    param (
        [switch]$csv,
        [string]$csvPath,
        [string]$serviceTag
    )
    # Set the users profile path based on the OS
    Set-UserProfilePath
    # Check if Token exists if it does not or has expired, create a new one
    Test-DellToken
    if ($csv) {
        # Check if a CSV file path was provided, if not set a default value.
        if (-not $csvPath){
            $csvPath = "Not Provided"
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
            Get-DellWarranty -serviceTag $csvServiceTag
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
                    # Break the entitlements array into separate lines
                    "Entitlements" = $entitlements | Out-String
                }
            }
            # Add the warranty information to an array
            $warrantyLineItems += New-Object PSObject -Property $warrantyLineItem
        }
        # Export the warranty information to a CSV file
        $warrantyLineItems | Export-Csv -Path "$env:USERPATH\DellWarranty-$($currentDateTime).csv" -Append -NoTypeInformation
        Write-Host "Warranty information for service tags exported to: $($env:USERPATH)\DellWarranty-$($currentDateTime).csv" -ForegroundColor Green
        # Clear the warranty object
        $script:warranty = $null
    } elseif (-not $serviceTag) {
        # If no service tag is provided, attempt to retrieve from local machine
        if (-not ((Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer) -eq "Dell Inc.")) {
            Write-Host "This script is only for Dell computers"
            Exit
        }
        write-host "Service Tag not provided, attempting to retrieve from local machine"
        $serialNumber = Get-WmiObject Win32_BIOS | Select-Object -ExpandProperty SerialNumber
        Get-DellWarranty -serviceTag $serialNumber
        if ($script:warranty.invalid -eq $true) {
            write-host "Incorrect service tag provided. Please provide a valid service tag." -ForegroundColor Red
        } else {
            return $warranty
        }
    } else {
        write-host "Service Tag provided, fetching warranty information"
        Get-DellWarranty -serviceTag $serviceTag
        if ($script:warranty.invalid -eq $true) {
            write-host "Incorrect service tag provided. Please provide a valid service tag." -ForegroundColor Red
        } else {
            return $warranty
        }
        }
    }