# Get-ServiceEntitlements

## SYNOPSIS
Retrieves the serial number and warranty information for Dell computers.

## DESCRIPTION
The `Get-ServiceEntitlements` function retrieves the serial number of a Dell computer and fetches its warranty information from Dell's service entitlement API. It can:

- Retrieve warranty information for a single Dell device by providing a service tag
- Automatically detect and query the service tag of the local Dell system
- Process multiple service tags from a CSV file
- Store credentials locally or in Azure Key Vault for secure authentication

The function supports two authentication methods:
1. Local credential storage in XML files
2. Azure Key Vault integration for enterprise-level credential management

## PARAMETERS

### -csv
A switch parameter that indicates a CSV file containing service tags will be processed.

```powershell
-csv
```

### -passThrough
A switch parameter to return objects directly to the pipeline instead of formatting output or exporting to CSV. This is useful for further processing of the warranty data.

```powershell
-passThrough
```

### -csvPath
The file path to the CSV file containing service tags. This parameter is only used when the `-csv` switch is specified.

```powershell
-csvPath <String>
```

### -serviceTag
The service tag of the Dell computer to query. If not provided, the function will attempt to retrieve the service tag from the local machine.

```powershell
-serviceTag <String>
```

### -UseKeyVault
A switch parameter that indicates Azure Key Vault should be used for credential storage and token management.

```powershell
-UseKeyVault
```

### -KeyVaultName
The name of the Azure Key Vault where Dell API credentials are stored. Required if `-UseKeyVault` is specified.

```powershell
-KeyVaultName <String>
```

### -ApiKeySecretName
The name of the secret in Key Vault that stores the Dell API Key. Defaults to "DellApiKey".

```powershell
-ApiKeySecretName <String>
```

### -ClientSecretName
The name of the secret in Key Vault that stores the Dell Client Secret. Defaults to "DellClientSecret".

```powershell
-ClientSecretName <String>
```

### -AuthTokenSecretName
The name of the secret in Key Vault that stores the Dell Auth Token. Defaults to "DellAuthToken".

```powershell
-AuthTokenSecretName <String>
```

## EXAMPLES

### Example 1: Get warranty information for the local Dell computer
```powershell
Get-ServiceEntitlements
```

This command retrieves the service tag from the local Dell computer and fetches its warranty information using local credential storage.

### Example 2: Get warranty information for a specific service tag
```powershell
Get-ServiceEntitlements -serviceTag "24WPX42"
```

This command fetches warranty information for the Dell device with service tag "24WPX42" using local credential storage.

### Example 3: Process service tags from a CSV file
```powershell
Get-ServiceEntitlements -csv -csvPath "C:\Temp\DellServiceTags.csv"
```

This command processes each service tag listed in the specified CSV file and exports the warranty information to a CSV file in the user's profile directory.

### Example 4: Use Azure Key Vault for credential storage
```powershell
Get-ServiceEntitlements -serviceTag "24WPX42" -UseKeyVault -KeyVaultName "MyKeyVault"
```

This command fetches warranty information for a specific service tag using credentials stored in the specified Azure Key Vault.

### Example 5: Process service tags from a CSV using Azure Key Vault
```powershell
Get-ServiceEntitlements -csv -csvPath "C:\Temp\DellServiceTags.csv" -UseKeyVault -KeyVaultName "MyKeyVault"
```

This command processes service tags from a CSV file using credentials stored in Azure Key Vault.

### Example 6: Get warranty information and pass through for further processing
```powershell
Get-ServiceEntitlements -serviceTag "24WPX42" -passThrough | Where-Object { $_.EntitlementType -eq "ProSupport" }
```

This command fetches warranty information for a specific service tag and returns the raw objects for further filtering or processing.

## CSV FILE FORMAT

The CSV file must contain a column named `ServiceTag` which contains the Dell service tags to be queried. For example:

```
ServiceTag
24WPX42
673W6S3
ABC123
```

If no CSV file is provided when using the `-csv` switch, the function will create a template CSV file and prompt the user to fill it in.

## OUTPUT

When processing a single service tag, the function returns a PowerShell object containing:

- Service tag
- ID
- Country code
- Product description
- System description
- Ship date
- Entitlements details including warranty start/end dates and service level information

When processing multiple service tags via CSV, it exports a CSV file containing the warranty information for all service tags to the user's profile directory with a filename like `DellWarranty-2025-06-24-16.49.36.csv`.

## AZURE KEY VAULT INTEGRATION

The function supports using Azure Key Vault for secure credential storage:

1. Store your Dell API Key and Client Secret in Key Vault using the `Set-DellKeyVaultSecrets` function
2. Use the `-UseKeyVault` and `-KeyVaultName` parameters to retrieve credentials from Key Vault
3. Authentication tokens are also stored and refreshed in Key Vault

Prerequisites for Key Vault integration:
- PowerShell 7.0 or higher
- Az PowerShell modules installed (`Install-Module -Name Az`)
- Appropriate permissions to access the specified Key Vault

## NOTES

- For CSV processing, the function creates an output CSV file containing warranty details for all service tags.
- API credentials are securely stored either locally or in Azure Key Vault.
- Authentication tokens are automatically refreshed when expired.
- When no service tag is provided, the function attempts to retrieve it from the local Dell computer using WMI.
- Azure Key Vault integration requires PowerShell 7.0 or higher and the Az PowerShell modules.

## RELATED LINKS

- [Dell Tech Direct API Key Request](https://techdirect.dell.com/Portal/ApplyForAPIKeyWizard.aspx)
- [GitHub Repository](https://github.com/WFord26/DellServiceEntitlements)
