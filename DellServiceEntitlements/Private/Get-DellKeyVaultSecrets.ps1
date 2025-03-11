# Get-DellKeyVaultSecrets.ps1

function Get-DellKeyVaultSecrets {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$KeyVaultName,
        [Parameter(Mandatory = $false)]
        [string]$ApiKeySecretName = "DellApiKey",
        [Parameter(Mandatory = $false)]
        [string]$ClientSecretName = "DellClientSecret",
        [Parameter(Mandatory = $false)]
        [string]$AuthTokenSecretName = "DellAuthToken"
    )

    try {
        # Verify Azure PowerShell modules are installed
        if (-not (Get-Module -ListAvailable Az.Accounts)) {
            Write-Error "Azure PowerShell modules not found. Please install using: Install-Module -Name Az -Scope CurrentUser"
            return
        }

        # Connect to Azure if not already connected
        $context = Get-AzContext
        if (-not $context) {
            Connect-AzAccount
        }

        # Retrieve secrets from Key Vault
        $apiKey = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $ApiKeySecretName
        $clientSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $ClientSecretName

        if (-not $apiKey -or -not $clientSecret) {
            Write-Error "Unable to retrieve Dell API credentials from Key Vault"
            return
        }

        # Convert secrets to usable format
        $script:userClientKey = $apiKey.SecretValue | ConvertFrom-SecureString -AsPlainText
        $script:userClientSecret = $clientSecret.SecretValue | ConvertFrom-SecureString -AsPlainText

        Write-Host "Successfully retrieved Dell API credentials from Azure Key Vault" -ForegroundColor Green
        return @{
            ApiKey = $script:userClientKey
            ClientSecret = $script:userClientSecret
        }
    }
    catch {
        Write-Error "Error retrieving secrets from Key Vault: $_"
    }
}