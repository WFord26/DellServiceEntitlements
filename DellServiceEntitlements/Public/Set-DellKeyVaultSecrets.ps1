function Set-DellKeyVaultSecrets {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$KeyVaultName,

    # Check PowerShell version first
    if (-not (Test-PowerShellVersion)) {
        return
    }
        [Parameter(Mandatory = $false)]
        [string]$ApiKeySecretName = "DellApiKey",
        [Parameter(Mandatory = $false)]
        [string]$ClientSecretName = "DellClientSecret",
        [Parameter(Mandatory = $false)]
        [string]$AuthTokenSecretName = "DellAuthToken",
        [Parameter(Mandatory = $false)]
        [switch]$UseExistingCredentials
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

        # Verify access to Key Vault
        try {
            Get-AzKeyVault -VaultName $KeyVaultName -ErrorAction Stop
        }
        catch {
            Write-Error "Unable to access Key Vault '$KeyVaultName'. Please verify the name and your permissions."
            return
        }

        if ($UseExistingCredentials) {
            # Import existing credentials from XML file
            $xmlPath = "$($script:userPath)apiCredential.xml"
            if (Test-Path $xmlPath) {
                $credential = Import-SavedCredential -target $xmlPath
                $apiKey = $credential.UserName
                $clientSecret = $credential.GetNetworkCredential().Password
            }
            else {
                Write-Error "No existing credentials found at $xmlPath"
                return
            }
        }
        else {
            # Prompt for new credentials
            $apiKey = Read-Host "Enter Dell API Key"
            $clientSecret = Read-Host "Enter Dell Client Secret" -AsSecureString
            $clientSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecret)
            )
        }

        # Store API Key
        $apiKeySecure = ConvertTo-SecureString $apiKey -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $ApiKeySecretName -SecretValue $apiKeySecure

        # Store Client Secret
        $clientSecretSecure = ConvertTo-SecureString $clientSecret -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $ClientSecretName -SecretValue $clientSecretSecure

        Write-Host "Successfully stored Dell API credentials in Azure Key Vault" -ForegroundColor Green
    }
    catch {
        Write-Error "Error storing secrets in Key Vault: $_"
    }
}