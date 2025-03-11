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