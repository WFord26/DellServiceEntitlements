# Set-DellKeyVaultSecrets

## ### -ClientSecret
The Dell API Client Secret to be stored in the Key Vault.

```powershell
-ClientSecret <String>
```

Required: Yes

### -ApiKeySecretName
The name to use for the API Key secret in the Key Vault. Defaults to "DellApiKey" if not specified.

```powershell
-ApiKeySecretName <String>
```

Required: No  
Default: "DellApiKey"

### -ClientIdSecretNameets Dell API credentials as secrets in an Azure Key Vault.

## DESCRIPTION
The `Set-DellKeyVaultSecrets` function securely stores Dell API credentials (Client ID and Client Secret) in an Azure Key Vault. This allows for secure management of API credentials in enterprise environments and integration with the DellServiceEntitlements module's Key Vault authentication mode.

The function validates Azure connectivity and Key Vault access before attempting to store the secrets. It provides options to overwrite existing secrets or preserve them.

## PARAMETERS

### -KeyVaultName
The name of the Azure Key Vault where Dell API credentials will be stored.

```powershell
-KeyVaultName <String>
```

Required: Yes

### -ClientId
The Dell API Client ID (also known as API Key) to be stored in the Key Vault.

```powershell
-ClientId <String>
```

Required: Yes

### -ClientSecret
The Dell API Client Secret to be stored in the Key Vault.

```powershell
-ClientSecret <String>
```

Required: Yes

### -ApiKeySecretName
The name to use for the API Key secret in the Key Vault. Defaults to "DellApiKey" if not specified.

```powershell
-ApiKeySecretName <String>
```

Required: No  
Default: "DellApiKey"

### -ClientIdSecretName
The name to use for the Client ID secret in the Key Vault. Defaults to "DellClientId" if not specified.

```powershell
-ClientIdSecretName <String>
```

Required: No  
Default: "DellClientId"

### -ClientSecretName
The name to use for the Client Secret in the Key Vault. Defaults to "DellClientSecret" if not specified.

```powershell
-ClientSecretName <String>
```

Required: No  
Default: "DellClientSecret"

### -Force
A switch parameter that forces overwriting of existing secrets in the Key Vault. If not specified and secrets already exist, a warning is displayed.

```powershell
-Force
```

Required: No

## EXAMPLES

### Example 1: Store Dell API credentials in a Key Vault
```powershell
Set-DellKeyVaultSecrets -KeyVaultName "MyKeyVault" -ClientId "ApiKey123456" -ClientSecret "SecretValue789012"
```

This command stores the Dell API credentials in the specified Key Vault with default secret names.

### Example 2: Store Dell API credentials with custom secret names
```powershell
Set-DellKeyVaultSecrets -KeyVaultName "MyKeyVault" -ClientId "ApiKey123456" -ClientSecret "SecretValue789012" -ApiKeySecretName "MyDellApiKey" -ClientIdSecretName "MyDellClientId" -ClientSecretName "MyDellClientSecret"
```

This command stores the Dell API credentials in the specified Key Vault with custom secret names.

### Example 3: Force overwrite existing secrets
```powershell
Set-DellKeyVaultSecrets -KeyVaultName "MyKeyVault" -ClientId "ApiKey123456" -ClientSecret "SecretValue789012" -Force
```

This command stores the Dell API credentials in the specified Key Vault, overwriting any existing secrets with the same names.

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

- This function is part of the DellServiceEntitlements module and is designed to work with its Key Vault authentication mode.
- Secrets are stored securely in Azure Key Vault and can be accessed by other functions in the module that use the `-UseKeyVault` parameter.
- The function requires an active Azure connection. If not already connected, use `Connect-AzAccount` before running this function.
- Ensure you have appropriate permissions to the Key Vault (at least Secret Management permissions).
- If secrets with the specified names already exist in the Key Vault, the function will display a warning unless the `-Force` parameter is used.

## ERROR HANDLING

The function provides detailed error messages for common issues:
- Not connected to Azure
- Key Vault not found
- Insufficient permissions
- Existing secrets when `-Force` is not specified

## RELATED LINKS

- [Azure Key Vault Documentation](https://docs.microsoft.com/en-us/azure/key-vault/)
- [Dell Tech Direct API Key Request](https://techdirect.dell.com/Portal/ApplyForAPIKeyWizard.aspx)
- [GitHub Repository](https://github.com/WFord26/DellServiceEntitlements)
