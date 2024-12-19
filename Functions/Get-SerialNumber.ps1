<#
.SYNOPSIS
Retrieves the serial number and warranty information for Dell computers.

.DESCRIPTION
The Get-SerialNumber function retrieves the serial number of a Dell computer and fetches its warranty information. 
It can also process a CSV file containing multiple service tags and fetch warranty information for each.

.PARAMETER csv
A boolean parameter indicating whether to process a CSV file containing service tags.

.PARAMETER csvPath
The file path to the CSV file containing service tags. This parameter is required if the csv parameter is set to $true.

.PARAMETER serviceTag
The service tag of the Dell computer. If not provided, the function will attempt to retrieve the service tag from the local machine.

.EXAMPLE
Get-SerialNumber -csv $true -csvPath "C:\path\to\file.csv"
Fetches warranty information for each service tag listed in the specified CSV file.

.EXAMPLE
Get-SerialNumber -serviceTag "ABC1234"
Fetches warranty information for the specified service tag.

.EXAMPLE
Get-SerialNumber
Fetches the serial number and warranty information for the local Dell computer.

.NOTES
This script is intended for use with Dell computers only. It checks if the computer is a Dell machine before attempting to retrieve the serial number.
#>
function Get-SerialNumber{
    [CmdletBinding()]
    param (
        [bool]$csv = $false,
        [string]$csvPath,
        [string]$serviceTag
    )
    # Check if Token exists if it does not or has expired, create a new one
    Test-DellToken
    if ($csv -eq $true) {
        if (-not (Test-Path $csvPath)) {
            Write-Host "CSV file not found at path: $csvPath"
            Exit
        }

        $csvContent = Import-Csv -Path $csvPath
        foreach ($row in $csvContent) {
            $csvServiceTag = $row.ServiceTag
            $warranty = Get-DellWarranty -serviceTag $csvServiceTag
            $warranty | Out-File -FilePath "$($csvPath).json" -Append
        }
    }
    # If no service tag is provided, attempt to retrieve from local machine
    elseif (-not $serviceTag) {
        if (-not ((Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer) -eq "Dell Inc.")) {
            Write-Host "This script is only for Dell computers"
            Exit
        }
        write-host "Service Tag not provided, attempting to retrieve from local machine"
        $serialNumber = Get-WmiObject Win32_BIOS | Select-Object -ExpandProperty SerialNumber
        Get-DellWarranty -serviceTag $serialNumber
        if ($warranty.invalid -eq $true) {
            write-host "Incorrect service tag provided. Please provide a valid service tag." -ForegroundColor Red
        } else {
            return $warranty
        }
    } else {
        write-host "Service Tag provided, fetching warranty information"
        Get-DellWarranty -serviceTag $serviceTag
        if ($warranty.invalid -eq $true) {
            write-host "Incorrect service tag provided. Please provide a valid service tag." -ForegroundColor Red
        } else {
            return $warranty
        }
    }
}
