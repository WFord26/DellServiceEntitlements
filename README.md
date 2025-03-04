# DellServiceEntitlements PowerShell Module

## Overview

The `DellServiceEntitlements` PowerShell module provides cmdlets to interact with Dell's service entitlement API. This module allows users to retrieve warranty and service information for Dell devices. It supports both local credential storage and Azure Key Vault integration for secure credential management in enterprise environments.

## Requirements

This module requires the following:

- PowerShell 5.1 or later for basic functionality
- PowerShell 7.0 or later for Azure Key Vault integration
- An API key and secret provided by Dell. You can obtain this on the [Dell Tech Direct](https://techdirect.dell.com/Portal/ApplyForAPIKeyWizard.aspx)
- Internet connectivity to access Dell's service entitlement API
- Administrator privileges to install the module
- For Azure Key Vault functionality:
  - Azure PowerShell module (`Az`) installed
  - Access to an Azure Key Vault
  - Appropriate Azure permissions (Key Vault Secrets Officer or equivalent)

## Installation

To install the `DellServiceEntitlements` module, follow these steps:

1. Download the latest release from the [GitHub releases page](https://github.com/WFord26/DellServiceEntitlements/releases)
2. Extract the downloaded file to a directory of your choice
3. Install required Azure PowerShell modules (if using Key Vault):
```powershell
Install-Module -Name Az -Scope CurrentUser
```
4. Open PowerShell and navigate to the directory where you extracted the files
5. Run the following command from the file root to import the module:
```powershell
Import-Module -Name .\DellServiceEntitlements.psm1
```

## Usage

### Import the Module

Before using the cmdlets, import the module:

```powershell
Import-Module -name '/location/to/DellServiceEntitlements/DellServiceEntitlements/DellServiceEntitlements.psm1'
```

### Configure Azure Key Vault (Optional)

If you want to use Azure Key Vault for credential storage:

1. Store your Dell API credentials in Key Vault:
```powershell
Set-DellKeyVaultSecrets -KeyVaultName "YourKeyVaultName"
```

2. Or import existing credentials to Key Vault:
```powershell
Set-DellKeyVaultSecrets -KeyVaultName "YourKeyVaultName" -UseExistingCredentials
```

3. Export Key Vault credentials to local storage:
```powershell
# Export to default location (\.dell\apiCredential.xml)
Export-DellKeyVaultToXml -KeyVaultName "YourKeyVaultName"

# Export to specific location
Export-DellKeyVaultToXml -KeyVaultName "YourKeyVaultName" -OutputPath "C:\path\to\credentials.xml"

# Force overwrite of existing file
Export-DellKeyVaultToXml -KeyVaultName "YourKeyVaultName" -Force
```

## Cmdlets

### Get-ServiceEntitlements

Retrieves the Entitlement information depending on what parameters are passed to it. 

#### Parameters

- `-serviceTag` (String): The service tag of the Dell device
- `-csv` (Boolean): Are you providing a CSV file or not
- `-csvPath` (String): Location of the CSV file that you wish to run through
- `-UseKeyVault` (Switch): Use Azure Key Vault for credential storage
- `-KeyVaultName` (String): Name of the Azure Key Vault
- `-ApiKeySecretName` (String): Optional. Name of API Key secret in Key Vault (default: "DellApiKey")
- `-ClientSecretName` (String): Optional. Name of Client Secret in Key Vault (default: "DellClientSecret")
- `-AuthTokenSecretName` (String): Optional. Name of Auth Token secret in Key Vault (default: "DellAuthToken")

#### Examples

**Using Local Storage:**

```powershell
# Searching for a specific service tag
Get-ServiceEntitlements -serviceTag 24WPX42  

# Searching with system local service tag
Get-ServiceEntitlements

# Searching with a CSV
Get-ServiceEntitlements -csv -csvPath "C:\Temp\DellServiceTags.csv"
```

**Using Azure Key Vault:**

```powershell
# Searching for a specific service tag with Key Vault
Get-ServiceEntitlements -serviceTag 24WPX42 -UseKeyVault -KeyVaultName "YourKeyVault"

# Process a CSV file using Key Vault credentials
Get-ServiceEntitlements -csv -csvPath "C:\Temp\DellServiceTags.csv" -UseKeyVault -KeyVaultName "YourKeyVault"

# Using custom secret names in Key Vault
Get-ServiceEntitlements -serviceTag 24WPX42 -UseKeyVault -KeyVaultName "YourKeyVault" `
    -ApiKeySecretName "CustomApiKey" -ClientSecretName "CustomClientSecret"
```

### Key Vault Management Cmdlets

#### Set-DellKeyVaultSecrets
Stores Dell API credentials in Azure Key Vault.

```powershell
# Store new credentials
Set-DellKeyVaultSecrets -KeyVaultName "YourKeyVault"

# Import existing credentials
Set-DellKeyVaultSecrets -KeyVaultName "YourKeyVault" -UseExistingCredentials
```

#### Get-DellKeyVaultSecrets
Retrieves Dell API credentials from Azure Key Vault.

```powershell
Get-DellKeyVaultSecrets -KeyVaultName "YourKeyVault"
```

#### Export-DellKeyVaultToXml
Exports Dell API credentials from Azure Key Vault to local XML storage.

```powershell
# Export to default location
Export-DellKeyVaultToXml -KeyVaultName "YourKeyVault"

# Export with custom settings
Export-DellKeyVaultToXml -KeyVaultName "YourKeyVault" `
    -OutputPath "C:\path\to\credentials.xml" `
    -ApiKeySecretName "CustomApiKey" `
    -ClientSecretName "CustomClientSecret" `
    -Force
```

## CSV File Format

The CSV file requires a column named `ServiceTag`. If a CSV is not passed or passed with an incorrect table header, it will create one and open it for the user to paste the ServiceTag values.

Example CSV format:
```csv
ServiceTag
24WPX42
7B2VX32
9C3NP12
```

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss any changes.

## License

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Contact

For any questions or issues, please contact [wford@managedsolution.com](mailto:wford@managedsolution.com).