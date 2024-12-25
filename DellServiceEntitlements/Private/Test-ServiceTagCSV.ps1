
<#PSScriptInfo

.VERSION 0.0.2

.GUID 8f2409f9-2bba-4b29-a9fb-1fcfc45f9e83

.AUTHOR wford@managedsolution.com

.COMPANYNAME Managed Solution

.COPYRIGHT

.TAGS Dell Service Tag Entitlements

.LICENSEURI

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
 This will test the passed in Service Tag CSV file 

#> 
Param()
function Test-ServiceTagCSV {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    # Check if the CSV file exists
    $csvPath = $Path
    if ($csvPath -eq "Not Provided") {
        Write-Host "CSV file not found at path: $csvPath"
        Write-Host "Would you like us to create a new CSV file? (Y/N)"
        $createCsv = Read-Host
        if ($createCsv -eq "Y") {
           New-DellTemplateCSV -Path $script:csvOutPath
        } else {
            Write-Host "Exiting script"
            Exit
        }
    } else {
        Write-Verbose "Processing CSV file: $csvPath"
        $script:csvContent = Import-Csv -Path $csvPath
        # Confirm that the CSV file contains a ServiceTag column
        if (-not $script:csvContent.ServiceTag) {
            Write-Host "CSV file must contain a column named 'ServiceTag'"
            Write-Host "Would you like us to create a new CSV file? (Y/N)"
            $createCsv = Read-Host
            if ($createCsv -eq "Y") {
            New-DellTemplateCSV -Path $script:csvOutPath
            } else {
                Write-Host "Exiting script"
                Exit
            }
        }
    }
}


