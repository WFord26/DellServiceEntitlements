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
        [Parameter(Mandatory = $true)]
        [string]$serviceTag,
        [switch]$UseKeyVault,
        [string]$KeyVaultName,
        [string]$AuthTokenSecretName = "DellAuthToken"
    )

    if ($UseKeyVault) {
        # Get token from Key Vault
        try {
            $tokenSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $AuthTokenSecretName -ErrorAction Stop
            if ($tokenSecret) {
                $tokenDetails = $tokenSecret.SecretValue | ConvertFrom-SecureString -AsPlainText | ConvertFrom-Json
                # Check if token has expired
                if ([DateTime]$tokenDetails.Expires -lt (Get-Date)) {
                    Write-Host "Token has expired, creating new Auth Token" -ForegroundColor Yellow
                    Get-DellApiKey -UseKeyVault -KeyVaultName $KeyVaultName
                    Grant-DellToken
                    Update-DellKeyVaultToken -KeyVaultName $KeyVaultName -AuthTokenSecretName $AuthTokenSecretName
                    # Get the new token
                    $tokenSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $AuthTokenSecretName
                    $tokenDetails = $tokenSecret.SecretValue | ConvertFrom-SecureString -AsPlainText | ConvertFrom-Json
                }
                $token = $tokenDetails.Token
            } else {
                Write-Host "No token found in Key Vault, creating new Auth Token" -ForegroundColor Yellow
                Get-DellApiKey -UseKeyVault -KeyVaultName $KeyVaultName
                Grant-DellToken
                Update-DellKeyVaultToken -KeyVaultName $KeyVaultName -AuthTokenSecretName $AuthTokenSecretName
                # Get the new token
                $tokenSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $AuthTokenSecretName
                $tokenDetails = $tokenSecret.SecretValue | ConvertFrom-SecureString -AsPlainText | ConvertFrom-Json
                $token = $tokenDetails.Token
            }
        }
        catch {
            Write-Host "Error with Key Vault token, creating new Auth Token" -ForegroundColor Yellow
            Get-DellApiKey -UseKeyVault -KeyVaultName $KeyVaultName
            Grant-DellToken
            Update-DellKeyVaultToken -KeyVaultName $KeyVaultName -AuthTokenSecretName $AuthTokenSecretName
            # Get the new token
            $tokenSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $AuthTokenSecretName
            $tokenDetails = $tokenSecret.SecretValue | ConvertFrom-SecureString -AsPlainText | ConvertFrom-Json
            $token = $tokenDetails.Token
        }
    } else {
        # Get token from local storage
        if (Test-Path "$($script:userPath)dellAuthToken.xml") {
            $dellAuthToken = Import-Clixml -Path "$($script:userPath)dellAuthToken.xml"
            $token = $dellAuthToken.token
        } else {
            Write-Host "No local token found, creating new Auth Token" -ForegroundColor Yellow
            Get-DellApiKey
            Grant-DellToken
            $dellAuthToken = Import-Clixml -Path "$($script:userPath)dellAuthToken.xml"
            $token = $dellAuthToken.token
        }
    }

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")
    
    $warrantyUrl = "https://apigtwb2c.us.dell.com/PROD/sbil/eapi/v5/asset-entitlements?servicetags=$serviceTag"
    
    try {
        $warrantyResponse = Invoke-RestMethod -Uri $warrantyUrl -Method Get -Headers $headers
        $Script:warranty = $warrantyResponse
    }
    catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 401) {
            Write-Host "Authentication token expired, creating new Auth Token" -ForegroundColor Yellow
            if ($UseKeyVault) {
                Get-DellApiKey -UseKeyVault -KeyVaultName $KeyVaultName
                Grant-DellToken
                Update-DellKeyVaultToken -KeyVaultName $KeyVaultName -AuthTokenSecretName $AuthTokenSecretName
                # Retry the warranty request with new token
                Get-DellWarranty -serviceTag $serviceTag -UseKeyVault -KeyVaultName $KeyVaultName -AuthTokenSecretName $AuthTokenSecretName
            } else {
                Get-DellApiKey
                Grant-DellToken
                # Retry the warranty request with new token
                Get-DellWarranty -serviceTag $serviceTag
            }
        } else {
            Write-Error "Error retrieving warranty information: $_"
            return
        }
    }
}