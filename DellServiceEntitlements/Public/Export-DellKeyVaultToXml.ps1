<#
.SYNOPSIS
Exports Dell API credentials from Azure Key Vault to a local XML file.

.DESCRIPTION
The Export-DellKeyVaultToXml function retrieves Dell API credentials (API Key and Client Secret) from an Azure Key Vault and exports them to a local XML file. This allows for transitioning from Key Vault-based authentication to local credential storage in the DellServiceEntitlements module.

The function validates Azure connectivity and Key Vault access before retrieving the secrets. It converts the secrets into a PSCredential object and securely stores them in an XML file using PowerShell's Export-Clixml cmdlet.

.PARAMETER KeyVaultName
The name of the Azure Key Vault where Dell API credentials are stored.

.PARAMETER ApiKeySecretName
Optional. The name of the secret in Key Vault that stores the Dell API Key. Defaults to "DellApiKey".

.PARAMETER ClientSecretName
Optional. The name of the secret in Key Vault that stores the Dell Client Secret. Defaults to "DellClientSecret".

.PARAMETER OutputPath
Optional. The file path where the exported XML file will be saved. If not specified, the file will be saved to a default location based on the operating system:
- Windows: %USERPROFILE%\.dell\apiCredential.xml
- Linux/macOS: $HOME/.dell/apiCredential.xml

.PARAMETER Force
Optional. A switch parameter that forces overwriting of the output file if it already exists. If not specified and the output file exists, an error is displayed.

.EXAMPLE
Export-DellKeyVaultToXml -KeyVaultName "MyKeyVault"
Retrieves Dell API credentials from the specified Key Vault and exports them to the default location.

.EXAMPLE
Export-DellKeyVaultToXml -KeyVaultName "MyKeyVault" -ApiKeySecretName "MyDellApiKey" -ClientSecretName "MyDellClientSecret"
Retrieves Dell API credentials using custom secret names and exports them to the default location.

.EXAMPLE
Export-DellKeyVaultToXml -KeyVaultName "MyKeyVault" -OutputPath "C:\Credentials\DellApi.xml"
Retrieves Dell API credentials and exports them to the specified custom file path.

.EXAMPLE
Export-DellKeyVaultToXml -KeyVaultName "MyKeyVault" -OutputPath "C:\Credentials\DellApi.xml" -Force
Retrieves Dell API credentials and exports them to the specified file path, overwriting the file if it already exists.

.NOTES
- Requires Azure PowerShell modules (Az.Accounts and Az.KeyVault)
- Requires valid Azure credentials with appropriate permissions to the specified Key Vault
- PowerShell 7.0 or higher is recommended for Azure Key Vault operations
- The exported credentials are stored securely in an XML file using PowerShell's secure credential serialization

.LINK
https://github.com/WFord26/DellServiceEntitlements

.LINK
https://docs.microsoft.com/en-us/azure/key-vault/

#>
function Export-DellKeyVaultToXml {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$KeyVaultName,
        [Parameter(Mandatory = $false)]
        [string]$ApiKeySecretName = "DellApiKey",
        [Parameter(Mandatory = $false)]
        [string]$ClientSecretName = "DellClientSecret",
        [Parameter(Mandatory = $false)]
        [string]$OutputPath,
        [switch]$Force
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

        # Retrieve secrets from Key Vault
        $apiKey = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $ApiKeySecretName
        $clientSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $ClientSecretName

        if (-not $apiKey -or -not $clientSecret) {
            Write-Error "Unable to retrieve Dell API credentials from Key Vault"
            return
        }

        # Set default output path if not specified
        if (-not $OutputPath) {
            # Set the users profile path based on the OS
            if ($env:OS -eq "Windows_NT") {
                $userPath = "$($env:USERPROFILE)\.dell\"
            } else {
                $userPath = "$($env:HOME)/.dell/"
            }
            
            # Create directory if it doesn't exist
            if (-not (Test-Path $userPath)) {
                New-Item -ItemType Directory -Path $userPath -Force | Out-Null
            }
            
            $OutputPath = Join-Path $userPath "apiCredential.xml"
        }

        # Check if file exists and Force wasn't specified
        if ((Test-Path $OutputPath) -and -not $Force) {
            Write-Error "File already exists at $OutputPath. Use -Force to overwrite."
            return
        }

        # Convert secrets to PSCredential object
        $apiKeyPlain = $apiKey.SecretValue | ConvertFrom-SecureString -AsPlainText
        $clientSecretSecure = $clientSecret.SecretValue
        $credential = New-Object -TypeName PSCredential -ArgumentList $apiKeyPlain, $clientSecretSecure

        # Export to XML
        $credential | Export-Clixml -Path $OutputPath -Force

        Write-Host "Successfully exported Key Vault credentials to: $OutputPath" -ForegroundColor Green
        
        return $OutputPath
    }
    catch {
        Write-Error "Error exporting credentials from Key Vault: $_"
    }
}