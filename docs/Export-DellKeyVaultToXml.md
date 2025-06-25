# Export-DellKeyVaultToXml

## SYNOPSIS
Exports Dell API credentials from Azure Key Vault to a local XML file.

## DESCRIPTION
The `Export-DellKeyVaultToXml` function retrieves Dell API credentials (API Key and Client Secret) from an Azure Key Vault and exports them to a local XML file. This allows for transitioning from Key Vault-based authentication to local credential storage in the DellServiceEntitlements module.

The function validates Azure connectivity and Key Vault access before retrieving the secrets. It converts the secrets into a PSCredential object and securely stores them in an XML file using PowerShell's Export-Clixml cmdlet.

## PARAMETERS

### -KeyVaultName
The name of the Azure Key Vault where Dell API credentials are stored.

```powershell
-KeyVaultName <String>
```

Required: Yes

### -ApiKeySecretName
The name of the secret in Key Vault that stores the Dell API Key. Defaults to "DellApiKey" if not specified.

```powershell
-ApiKeySecretName <String>
```

Required: No  
Default: "DellApiKey"

### -ClientSecretName
The name of the secret in Key Vault that stores the Dell Client Secret. Defaults to "DellClientSecret" if not specified.

```powershell
-ClientSecretName <String>
```

Required: No  
Default: "DellClientSecret"

### -OutputPath
The file path where the exported XML file will be saved. If not specified, the file will be saved to a default location based on the operating system:
- Windows: `%USERPROFILE%\.dell\apiCredential.xml`
- Linux/macOS: `$HOME/.dell/apiCredential.xml`

```powershell
-OutputPath <String>
```

Required: No

### -Force
A switch parameter that forces overwriting of the output file if it already exists. If not specified and the output file exists, an error is displayed.

```powershell
-Force
```

Required: No

## EXAMPLES

### Example 1: Export credentials using default parameters
```powershell
Export-DellKeyVaultToXml -KeyVaultName "MyKeyVault"
```

This command retrieves Dell API credentials from the specified Key Vault and exports them to the default location.

### Example 2: Export credentials with custom secret names
```powershell
Export-DellKeyVaultToXml -KeyVaultName "MyKeyVault" -ApiKeySecretName "MyDellApiKey" -ClientSecretName "MyDellClientSecret"
```

This command retrieves Dell API credentials using custom secret names and exports them to the default location.

### Example 3: Export credentials to a custom location
```powershell
Export-DellKeyVaultToXml -KeyVaultName "MyKeyVault" -OutputPath "C:\Credentials\DellApi.xml"
```

This command retrieves Dell API credentials and exports them to the specified custom file path.

### Example 4: Force overwrite of an existing file
```powershell
Export-DellKeyVaultToXml -KeyVaultName "MyKeyVault" -OutputPath "C:\Credentials\DellApi.xml" -Force
```

This command retrieves Dell API credentials and exports them to the specified file path, overwriting the file if it already exists.

## PREREQUISITES

- Azure PowerShell modules (Az.Accounts and Az.KeyVault) must be installed
- Valid Azure credentials with appropriate permissions to the specified Key Vault
- PowerShell 7.0 or higher is recommended for Azure Key Vault operations

To install the required Azure PowerShell modules:

```powershell
Install-Module -Name Az.Accounts, Az.KeyVault -Force
```

To connect to Azure before running this function:

```powershell
Connect-AzAccount
```

## NOTES

- This function is part of the DellServiceEntitlements module and is designed to facilitate transition between Key Vault authentication and local credential storage.
- The exported credentials are stored securely in an XML file using PowerShell's secure credential serialization.
- The function requires an active Azure connection. If not already connected, it will attempt to connect using Connect-AzAccount.
- Ensure you have appropriate permissions to the Key Vault (at least Secret Read permissions).
- If the output file already exists and the `-Force` parameter is not used, the function will display an error message.
- The function creates the output directory if it doesn't exist.
- The XML file stores credentials in a format compatible with the DellServiceEntitlements module's local authentication method.

## RETURN VALUE

The function returns the path to the exported XML file if successful.

## ERROR HANDLING

The function provides detailed error messages for common issues:
- Azure PowerShell modules not installed
- Not connected to Azure
- Key Vault not found or inaccessible
- Unable to retrieve secrets from Key Vault
- Output file already exists when `-Force` is not specified

## RELATED LINKS

- [Azure Key Vault Documentation](https://docs.microsoft.com/en-us/azure/key-vault/)
- [PowerShell Export-Clixml](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-clixml)
- [GitHub Repository](https://github.com/WFord26/DellServiceEntitlements)
