# Update-DellKeyVaultToken.ps1

function Update-DellKeyVaultToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$KeyVaultName,
        [Parameter(Mandatory = $false)]
        [string]$AuthTokenSecretName = "DellAuthToken"
    )

    try {
        Write-Verbose "Updating token in Key Vault. Token expires: $($script:dellAuthToken.expires)"
        
        $tokenDetails = @{
            Token = $script:dellAuthToken.token
            Expires = $script:dellAuthToken.expires.ToString('o')  # ISO 8601 format
            RequestTime = (Get-Date).ToString('o')  # ISO 8601 format
        } | ConvertTo-Json

        Write-Verbose "Token details to store: $tokenDetails"

        $tokenSecure = ConvertTo-SecureString $tokenDetails -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $AuthTokenSecretName -SecretValue $tokenSecure

        Write-Host "Successfully updated Dell authentication token in Azure Key Vault" -ForegroundColor Green
    }
    catch {
        Write-Error "Error updating auth token in Key Vault: $_"
    }
}