<#
.SYNOPSIS
    Tests the validity of the Dell API authentication token and generates a new one if necessary.

.DESCRIPTION
    The Test-DellToken function checks if the Dell API authentication token exists and is valid. 
    If the token does not exist or has expired, it generates a new authentication token using stored credentials.

.PARAMETER None
    This function does not take any parameters.

.EXAMPLE
    PS C:\> Test-DellToken
    Checks the Dell API authentication token and generates a new one if necessary.

.NOTES
    The function relies on the presence of the Get-DellApiKey, Grant-DellToken, and Import-SavedCredential functions.
    The authentication token is stored in an XML file located at "$env:USERPROFILE\.dell\dellAuthToken.xml".
    The credentials for generating a new token are stored in an XML file located at "$env:USERPROFILE\.dell\apiCredential.xml".

#>

function Test-DellToken {
    [CmdletBinding()]
    param (
        [switch]$UseKeyVault,
        [string]$KeyVaultName,
        [string]$AuthTokenSecretName = "DellAuthToken"
    )

    if ($UseKeyVault) {
        if (-not $KeyVaultName) {
            Write-Error "KeyVaultName is required when using Azure Key Vault"
            return
        }

        try {
            $tokenSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $AuthTokenSecretName -ErrorAction Stop
            if ($tokenSecret) {
                $tokenDetails = $tokenSecret.SecretValue | ConvertFrom-SecureString -AsPlainText | ConvertFrom-Json
                
                # Ensure we have all required properties
                if (-not $tokenDetails.Token -or -not $tokenDetails.Expires) {
                    Write-Verbose "Token details incomplete, creating new token"
                    Get-DellApiKey -UseKeyVault -KeyVaultName $KeyVaultName
                    $newToken = Grant-DellToken
                    if ($newToken) {
                        Update-DellKeyVaultToken -KeyVaultName $KeyVaultName -AuthTokenSecretName $AuthTokenSecretName
                    }
                    return
                }

                # Convert expiration date string to DateTime
                $expirationDate = [DateTime]::Parse($tokenDetails.Expires)
                Write-Verbose "Token expires at: $expirationDate"
                Write-Verbose "Current time: $(Get-Date)"

                if ($expirationDate -lt (Get-Date)) {
                    Write-Host "Token has expired, creating new Auth Token" -ForegroundColor Yellow
                    Get-DellApiKey -UseKeyVault -KeyVaultName $KeyVaultName
                    $newToken = Grant-DellToken
                    if ($newToken) {
                        Update-DellKeyVaultToken -KeyVaultName $KeyVaultName -AuthTokenSecretName $AuthTokenSecretName
                    }
                } else {
                    Write-Verbose "Token is still valid. Expires in: $(($expirationDate - (Get-Date)).TotalMinutes) minutes"
                    $script:dellAuthToken = @{
                        token = $tokenDetails.Token
                        expires = $expirationDate
                    }
                }
            } else {
                Write-Host "No token found in Key Vault, creating new Auth Token" -ForegroundColor Yellow
                Get-DellApiKey -UseKeyVault -KeyVaultName $KeyVaultName
                $newToken = Grant-DellToken
                if ($newToken) {
                    Update-DellKeyVaultToken -KeyVaultName $KeyVaultName -AuthTokenSecretName $AuthTokenSecretName
                }
            }
        }
        catch {
            Write-Host "Error with Key Vault token, creating new Auth Token" -ForegroundColor Yellow
            Write-Verbose "Error details: $_"
            Get-DellApiKey -UseKeyVault -KeyVaultName $KeyVaultName
            $newToken = Grant-DellToken
            if ($newToken) {
                Update-DellKeyVaultToken -KeyVaultName $KeyVaultName -AuthTokenSecretName $AuthTokenSecretName
            }
        }
    } else {
        Get-DellApiKey
        $dellAuthTokenFile = "$($script:userPath)dellAuthToken.xml"
        if (-Not (Test-Path $dellAuthTokenFile)) {
            Write-Host "Token does not exist, creating new Auth Token" -ForegroundColor Yellow
            Get-DellApiKey
            Grant-DellToken
        } else {
            $dellAuthTokenImport = Import-Clixml -Path $dellAuthTokenFile
            if ($dellAuthTokenImport.expires -lt (Get-Date)) {
                Write-Host "Token has expired, creating new Auth Token" -ForegroundColor Yellow
                $credential = Import-SavedCredential -target "$($script:userPath)apiCredential.xml"
                $script:userClientKey = $credential.UserName
                $script:userClientSecret = $credential.GetNetworkCredential().Password
                Grant-DellToken
            }
        }
    }
}