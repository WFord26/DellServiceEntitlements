<#
.SYNOPSIS
Sets Dell API credentials as secrets in an Azure Key Vault.

.DESCRIPTION
This function stores Dell API Client ID and Client Secret as secrets in the specified Azure Key Vault.

.PARAMETER KeyVaultName
The name of the Azure Key Vault where secrets will be stored.

.PARAMETER ClientId
The Dell API Client ID to store as a secret.

.PARAMETER ClientSecret
The Dell API Client Secret to store as a secret.

.PARAMETER ApiKeySecretName
The name for the API key secret in Key Vault. Defaults to "DellApiKey".

.PARAMETER ClientIdSecretName
The name for the Client ID secret in Key Vault. Defaults to "DellClientId".

.PARAMETER ClientSecretName
The name for the Client Secret in Key Vault. Defaults to "DellClientSecret".

.PARAMETER Force
Forces overwriting of existing secrets without prompting.

.EXAMPLE
Set-DellKeyVaultSecrets -KeyVaultName "MyKeyVault" -ClientId "your-client-id" -ClientSecret "your-client-secret"
#>
function Set-DellKeyVaultSecrets {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$KeyVaultName,
        
        [Parameter(Mandatory = $true)]
        [string]$ClientId,
        
        [Parameter(Mandatory = $true)]
        [string]$ClientSecret,
        
        [Parameter(Mandatory = $false)]
        [string]$ApiKeySecretName = "DellApiKey",
        
        [Parameter(Mandatory = $false)]
        [string]$ClientIdSecretName = "DellClientId",
        
        [Parameter(Mandatory = $false)]
        [string]$ClientSecretName = "DellClientSecret",
        
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    # Verify Az.KeyVault module is available
    if (-not (Get-Module -ListAvailable -Name Az.KeyVault)) {
        Write-Error "The Az.KeyVault module is required. Please install it using: Install-Module -Name Az.KeyVault -Force"
        return
    }

    # Check if user is connected to Azure
    try {
        $context = Get-AzContext -ErrorAction Stop
        if (-not $context) {
            Write-Error "You are not connected to Azure. Please run Connect-AzAccount first."
            return
        }
    }
    catch {
        Write-Error "Error checking Azure connection: $_"
        Write-Error "Please run Connect-AzAccount to connect to Azure."
        return
    }

    # Check if the Key Vault exists
    try {
        $keyVault = Get-AzKeyVault -VaultName $KeyVaultName -ErrorAction Stop
        if (-not $keyVault) {
            Write-Error "Key Vault '$KeyVaultName' not found."
            return
        }
    }
    catch {
        Write-Error "Error accessing Key Vault '$KeyVaultName': $_"
        return
    }

    # Set secrets in Key Vault
    try {
        # Set the Client ID secret
        $existingClientIdSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $ClientIdSecretName -ErrorAction SilentlyContinue
        if ($existingClientIdSecret -and -not $Force) {
            Write-Warning "Secret '$ClientIdSecretName' already exists in '$KeyVaultName'. Use -Force to overwrite."
        }
        else {
            $clientIdSecureString = ConvertTo-SecureString -String $ClientId -AsPlainText -Force
            Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $ClientIdSecretName -SecretValue $clientIdSecureString | Out-Null
            Write-Output "Successfully stored Client ID as secret '$ClientIdSecretName' in Key Vault '$KeyVaultName'."
        }

        # Set the Client Secret
        $existingClientSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $ClientSecretName -ErrorAction SilentlyContinue
        if ($existingClientSecret -and -not $Force) {
            Write-Warning "Secret '$ClientSecretName' already exists in '$KeyVaultName'. Use -Force to overwrite."
        }
        else {
            $clientSecretSecureString = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
            Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $ClientSecretName -SecretValue $clientSecretSecureString | Out-Null
            Write-Output "Successfully stored Client Secret as secret '$ClientSecretName' in Key Vault '$KeyVaultName'."
        }
    }
    catch {
        Write-Error "Error storing secrets in Key Vault: $_"
    }
}