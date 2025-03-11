# DellServiceEntitlements PowerShell Module

## Overview

The `DellServiceEntitlements` PowerShell module provides cmdlets to interact with Dell's service entitlement API. This module allows users to retrieve warranty and service information for Dell devices.

## Features

- Retrieve warranty and service information for Dell devices using service tags
- Process multiple service tags via CSV file
- Automatically detect service tags from local Dell systems
- Securely store and manage Dell API credentials
- Support for both local credential storage and Azure Key Vault integration
- Cross-platform support (Windows, Linux, macOS)

## Requirements

This module requires the following:

- PowerShell 5.1 or later (PowerShell 7.0+ recommended for Azure Key Vault integration)
- An API key and secret provided by Dell. You can obtain this on the [Dell Tech Direct](https://techdirect.dell.com/Portal/ApplyForAPIKeyWizard.aspx).
- Internet connectivity to access Dell's service entitlement API.
- Administrator privileges to install the module.
- (Optional) Azure PowerShell modules for Key Vault integration

## Installation

To install the `DellServiceEntitlements` module, follow these steps:

1. Download the latest release from the [GitHub releases page](https://github.com/WFord26/DellServiceEntitlements/releases).
2. Extract the downloaded file to a directory of your choice.
3. Open PowerShell and navigate to the directory where you extracted the files.
4. Run the following command from the file root to import the module:

```powershell
Import-Module -Name .\DellServiceEntitlements.psd1
```

## Usage

### Import the Module

Before using the cmdlets, import the module:

```powershell
Import-Module -name '/location/to/DellServiceEntitlements/DellServiceEntitlements/DellServiceEntitlements.psd1'
```

## Authentication Methods

The module supports two authentication methods:

1. **Local Credential Storage**: Credentials are stored securely in XML files on the local system
2. **Azure Key Vault Integration**: Credentials are stored and managed securely in Azure Key Vault (recommended for enterprise environments)

### Setting up Azure Key Vault Integration

1. Install the required Azure PowerShell modules:

```powershell
Install-Module -Name Az.Accounts, Az.KeyVault -Force
```

2. Connect to your Azure account:

```powershell
Connect-AzAccount
```

3. Store your Dell API credentials in Key Vault:

```powershell
Set-DellKeyVaultSecrets -KeyVaultName "YourKeyVaultName" -ClientId "YourClientId" -ClientSecret "YourClientSecret"
```

## Cmdlets

### Get-ServiceEntitlements

Retrieves warranty and service information for Dell devices.

#### Parameters

- `-serviceTag` (String): The service tag of the Dell device.
- `-csv` (Boolean): Indicates that a CSV file containing service tags will be processed.
- `-csvPath` (String): Location of the CSV file that you wish to run through.
- `-UseKeyVault` (Switch): Indicates that Azure Key Vault should be used for credential storage.
- `-KeyVaultName` (String): The name of the Azure Key Vault where Dell API credentials are stored.
- `-ApiKeySecretName` (String): The name of the secret in Key Vault that stores the Dell API Key.
- `-ClientSecretName` (String): The name of the secret in Key Vault that stores the Dell Client Secret.
- `-AuthTokenSecretName` (String): The name of the secret in Key Vault that stores the Dell Auth Token.
- `-passThrough` (Switch): Are you passing this command through to another script.

#### Examples

**Query the local Dell system**

```powershell
Get-ServiceEntitlements
```

**Query a specific service tag**

```powershell
Get-ServiceEntitlements -serviceTag "24WPX42"
```

**Process a CSV file of service tags**

```powershell
Get-ServiceEntitlements -csv -csvPath "C:\Temp\DellServiceTags.csv"
```

**Use Azure Key Vault for authentication**

```powershell
Get-ServiceEntitlements -serviceTag "24WPX42" -UseKeyVault -KeyVaultName "MyKeyVault"
```

**Passthrough**
```powershell
Get-ServiceEntitlements -passThrough\
```


**Sample Outputs**

```powershell
PS C:\Users\wford.MS> Get-ServiceEntitlements -serviceTag 4J9CXC2
Token has expired, creating new Auth Token
Obtaining Dell token
Token created successfully

Name                           Value
----                           -----
token                          8851e5af-707b-42aa-a07f-fc352138ca55-1741733981
expires                        3/11/2025 4:59:41 PM
Service Tag provided, fetching warranty information
Country                        US
Start Date                     2/26/2018 6:00:00 AM
ID                             885080438
ServiceTag                     4J9CXC2
Product                        Dell Networking
System Type                    PowerSwitch N2000 Series
-------- Entitlement (1) --------
Warranty Type                  INITIAL
Service Level                  Next Business Day Parts Support
Start Date                     2/26/2018 6:00:00 AM
End Date                       3/10/2019 5:59:59 AM
-------- Entitlement (2) --------
Warranty Type                  INITIAL
Service Level                  Limited Lifetime/Extended Warranty
Start Date                     2/26/2018 6:00:00 AM
End Date                       3/10/2045 5:59:59 AM


PS C:\Users\wford.MS> Get-ServiceEntitlements
Service Tag not provided, attempting to retrieve from local machine

Name                           Value
----                           -----
Country                        US
Start Date                     2/24/2023 6:00:00 AM
ID                             2003316121
ServiceTag                     673W6S3
Product                        Latitude
System Type
-------- Entitlement (1) --------
Warranty Type                  INITIAL
Service Level                  Onsite Service After Remote Diagnosis (Consumer Customer)/ Next Business Day Onsite Aft…
Start Date                     2/24/2023 6:00:00 AM
End Date                       2/25/2024 5:59:59 AM



PS C:\Users\wford.MS> Get-ServiceEntitlements -passThrough
Service Tag not provided, attempting to retrieve from local machine

id                     : 2003316121
serviceTag             : 673W6S3
orderBuid              : 11
shipDate               : 2/24/2023 6:00:00 AM
productCode            : >/192
localChannel           : 45
productId              :
productLineDescription : LATITUDE 5530
productFamily          :
systemDescription      :
productLobDescription  : Latitude
countryCode            : US
duplicated             : False
invalid                : False
entitlements           : {@{itemNumber=997-8328; startDate=2/24/2023 6:00:00 AM; endDate=2/25/2024 5:59:59 AM;
                         entitlementType=INITIAL; serviceLevelCode=ND; serviceLevelDescription=Onsite Service After
                         Remote Diagnosis (Consumer Customer)/ Next Business Day Onsite After Remote Diagnosis (for
                         business Customer); serviceLevelGroup=5}}

```

### Set-DellKeyVaultSecrets

Stores Dell API credentials in Azure Key Vault.

#### Parameters

- `-KeyVaultName` (String): The name of the Azure Key Vault.
- `-ClientId` (String): The Dell API Client ID (API Key).
- `-ClientSecret` (String): The Dell API Client Secret.
- `-ApiKeySecretName` (String): The name to use for the API Key secret.
- `-ClientIdSecretName` (String): The name to use for the Client ID secret.
- `-ClientSecretName` (String): The name to use for the Client Secret.
- `-Force` (Switch): Forces overwriting of existing secrets.

#### Example

```powershell
Set-DellKeyVaultSecrets -KeyVaultName "MyKeyVault" -ClientId "ApiKey123456" -ClientSecret "SecretValue789012"
```

### Export-DellKeyVaultToXml

Exports Dell API credentials from Azure Key Vault to a local XML file.

#### Parameters

- `-KeyVaultName` (String): The name of the Azure Key Vault.
- `-ApiKeySecretName` (String): The name of the secret storing the Dell API Key.
- `-ClientSecretName` (String): The name of the secret storing the Dell Client Secret.
- `-OutputPath` (String): The file path where the exported XML file will be saved.
- `-Force` (Switch): Forces overwriting of the output file if it already exists.

#### Example

```powershell
Export-DellKeyVaultToXml -KeyVaultName "MyKeyVault" -OutputPath "C:\Credentials\DellApi.xml"
```

## CSV File Format

When using the `-csv` parameter with Get-ServiceEntitlements, the CSV file must contain a column named `ServiceTag`. For example:

```
ServiceTag
24WPX42
673W6S3
ABC123
```

If you don't provide a CSV file, the module will create a template file for you:

```powershell
Get-ServiceEntitlements -csv
```

## Cross-Platform Support

The module automatically detects the operating system and adjusts file paths accordingly:
- Windows: Uses `%USERPROFILE%\.dell\` for credential storage
- Linux/macOS: Uses `$HOME/.dell/` for credential storage

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss any changes.

## License

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Contact

For any questions or issues, please contact [wford@managedsolution.com](mailto:wford@managedsolution.com).