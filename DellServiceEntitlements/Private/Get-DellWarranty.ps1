<#
.SYNOPSIS
    Retrieves Dell warranty information for a given service tag.

.DESCRIPTION
    The Get-DellWarranty function sends a GET request to the Dell API to retrieve warranty information for a specified service tag. 
    The function requires a valid authorization token stored in the global variable $global:dellAuthToken.token.

.PARAMETER serviceTag
    The service tag of the Dell device for which to retrieve warranty information.

.EXAMPLE
    PS C:\> Get-DellWarranty -serviceTag "ABC1234"
    Retrieves the warranty information for the Dell device with the service tag "ABC1234".

.NOTES
    The function uses the Invoke-RestMethod cmdlet to send the GET request and stores the response in the $Script:warranty variable.
#>
function Get-DellWarranty {
    [CmdletBinding()]
    param (
        [string]$serviceTag
    )
    $dellAuthToken = Import-Clixml -Path "$env:USERPROFILE\.dell\dellAuthToken.xml"
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer "+ $($dellAuthToken.token))
    $warrantyUrl = "https://apigtwb2c.us.dell.com/PROD/sbil/eapi/v5/asset-entitlements?servicetags="+$serviceTag
    $warrantyResponse = Invoke-RestMethod -Uri $warrantyUrl -Method Get -Headers $headers
    $Script:warranty = $warrantyResponse 
}