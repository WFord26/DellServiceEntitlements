# DellServiceEntitlements PowerShell Module

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/DellServiceEntitlements)](https://www.powershellgallery.com/packages/DellServiceEntitlements)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/DellServiceEntitlements)](https://www.powershellgallery.com/packages/DellServiceEntitlements)

## Overview

The `DellServiceEntitlements` PowerShell module provides cmdlets to interact with Dell's service entitlement API. This module allows users to retrieve warranty and service information for Dell devices with comprehensive support for both local and cloud-based credential management.

## Features

- **Warranty Information Retrieval**: Get comprehensive warranty and service information for Dell devices using service tags
- **Bulk Processing**: Process multiple service tags via CSV file for enterprise scenarios
- **Auto-Detection**: Automatically detect service tags from local Dell systems
- **Secure Credential Management**: Securely store and manage Dell API credentials with multiple storage options
- **Azure Key Vault Integration**: Enterprise-grade credential storage and management through Azure Key Vault
- **Cross-Platform Support**: Full compatibility across Windows, Linux, and macOS
- **PassThrough Support**: Enhanced integration capabilities for use with other automation scripts
- **Comprehensive Documentation**: Detailed parameter descriptions and usage examples for all functions

## Requirements

This module requires the following:

- **PowerShell 7.0 or later** (required for Azure Key Vault integration and optimal performance)
- **Dell API Credentials**: An API key and secret provided by Dell. You can obtain this on the [Dell Tech Direct](https://techdirect.dell.com/Portal/ApplyForAPIKeyWizard.aspx)
- **Internet Connectivity**: Required to access Dell's service entitlement API
- **Azure PowerShell Modules** (for Key Vault integration): `Az.Accounts` and `Az.KeyVault`

### Optional Requirements
- Administrator privileges may be required for module installation in system-wide locations
- Azure subscription and Key Vault for enterprise credential management

## Installation

### From PowerShell Gallery (Recommended)

```powershell
# Install from PowerShell Gallery
Install-Module -Name DellServiceEntitlements -Force

# Import the module
Import-Module -Name DellServiceEntitlements
```

### From GitHub Releases

1. Download the latest release from the [GitHub releases page](https://github.com/WFord26/DellServiceEntitlements/releases)
2. Extract the downloaded file to a directory of your choice
3. Open PowerShell and navigate to the directory where you extracted the files
4. Import the module:

```powershell
Import-Module -Name .\DellServiceEntitlements\DellServiceEntitlements.psd1
```

### Verify Installation

```powershell
# Check module version
Get-Module -Name DellServiceEntitlements -ListAvailable

# View available commands
Get-Command -Module DellServiceEntitlements
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

Retrieves warranty and service information for Dell devices with support for single devices, bulk processing, and multiple authentication methods.

#### Parameters

**Core Parameters:**
- `-serviceTag` (String): The service tag of the specific Dell device to query
- `-csv` (Switch): Process multiple service tags from a CSV file
- `-csvPath` (String): Path to the CSV file containing service tags (creates template if not specified)
- `-passThrough` (Switch): Returns raw API response object for integration with other scripts

**Azure Key Vault Parameters:**
- `-UseKeyVault` (Switch): Use Azure Key Vault for credential storage and retrieval
- `-KeyVaultName` (String): Name of the Azure Key Vault containing Dell API credentials
- `-ApiKeySecretName` (String): Name of the Key Vault secret storing the Dell API Key (default: "DellApiKey")
- `-ClientSecretName` (String): Name of the Key Vault secret storing the Dell Client Secret (default: "DellClientSecret")
- `-AuthTokenSecretName` (String): Name of the Key Vault secret storing the Dell Auth Token (default: "DellAuthToken")

#### Examples

**Query the local Dell system (auto-detection)**
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

**Create a CSV template file**
```powershell
Get-ServiceEntitlements -csv
# Creates ServiceTags.csv template in current directory
```

**Use Azure Key Vault for authentication**
```powershell
Get-ServiceEntitlements -serviceTag "24WPX42" -UseKeyVault -KeyVaultName "MyKeyVault"
```

**Get raw API response for script integration**
```powershell
$warrantyData = Get-ServiceEntitlements -serviceTag "24WPX42" -passThrough
# Returns hashtable object instead of formatted output
```

**Bulk processing with Key Vault authentication**
```powershell
Get-ServiceEntitlements -csv -csvPath "C:\Data\Assets.csv" -UseKeyVault -KeyVaultName "Corp-KeyVault"
```


#### Sample Outputs

**Standard formatted output:**
```powershell
PS C:\> Get-ServiceEntitlements -serviceTag 4J9CXC2

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
```

**PassThrough output (raw API response):**
```powershell
PS C:\> Get-ServiceEntitlements -serviceTag 673W6S3 -passThrough

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

---

### Set-DellKeyVaultSecrets

Stores Dell API credentials securely in Azure Key Vault for enterprise credential management.

#### Parameters

**Required Parameters:**
- `-KeyVaultName` (String): The name of the Azure Key Vault
- `-ClientId` (String): The Dell API Client ID (API Key)  
- `-ClientSecret` (String): The Dell API Client Secret

**Optional Parameters:**
- `-ApiKeySecretName` (String): Custom name for the API Key secret (default: "DellApiKey")
- `-ClientIdSecretName` (String): Custom name for the Client ID secret (default: "DellClientId")
- `-ClientSecretName` (String): Custom name for the Client Secret (default: "DellClientSecret")
- `-Force` (Switch): Overwrites existing secrets without confirmation

#### Examples

**Basic usage:**
```powershell
Set-DellKeyVaultSecrets -KeyVaultName "MyKeyVault" -ClientId "ApiKey123456" -ClientSecret "SecretValue789012"
```

**With custom secret names:**
```powershell
Set-DellKeyVaultSecrets -KeyVaultName "Corp-KeyVault" -ClientId "ApiKey123456" -ClientSecret "SecretValue789012" -ApiKeySecretName "Dell-API-Key" -ClientSecretName "Dell-API-Secret"
```

---

### Export-DellKeyVaultToXml

Exports Dell API credentials from Azure Key Vault to a local XML file for backup or migration purposes.

#### Parameters

**Required Parameters:**
- `-KeyVaultName` (String): The name of the Azure Key Vault
- `-OutputPath` (String): The file path where the exported XML file will be saved

**Optional Parameters:**
- `-ApiKeySecretName` (String): Name of the secret storing the Dell API Key (default: "DellApiKey")
- `-ClientSecretName` (String): Name of the secret storing the Dell Client Secret (default: "DellClientSecret")
- `-Force` (Switch): Overwrites the output file if it already exists

#### Examples

**Basic export:**
```powershell
Export-DellKeyVaultToXml -KeyVaultName "MyKeyVault" -OutputPath "C:\Credentials\DellApi.xml"
```

**Export with custom secret names:**
```powershell
Export-DellKeyVaultToXml -KeyVaultName "Corp-KeyVault" -OutputPath "D:\Backups\Dell-Credentials.xml" -ApiKeySecretName "Dell-API-Key" -ClientSecretName "Dell-API-Secret" -Force
```

---

---

## Recent Improvements (v0.4.3)

### Enhanced Documentation
- **Comprehensive Parameter Documentation**: All functions now include detailed parameter descriptions with examples
- **Improved Help System**: Enhanced Get-Help support with practical usage examples
- **Better Error Messages**: More descriptive error handling and troubleshooting guidance

### New Features
- **PassThrough Support**: Added `-passThrough` parameter for better script integration and automation
- **Enhanced Testing**: Improved Pester test coverage with better module scoping and Azure Key Vault mocking
- **Cross-Platform Compatibility**: Enhanced support for Windows, Linux, and macOS environments

### Performance & Reliability
- **Optimized Token Management**: Improved authentication token handling and renewal
- **Better Error Handling**: Enhanced resilience for network timeouts and API failures
- **Improved Credential Security**: Strengthened credential storage and retrieval mechanisms

---

## CSV File Format

When using the `-csv` parameter with `Get-ServiceEntitlements`, the CSV file must contain a column named `ServiceTag`. For example:

```csv
ServiceTag
24WPX42
673W6S3
ABC123
```

If you don't provide a CSV file, the module will create a template file for you:

```powershell
Get-ServiceEntitlements -csv
# Creates ServiceTags.csv template in current directory
```

## Cross-Platform Support

The module automatically detects the operating system and adjusts file paths accordingly:
- **Windows**: Uses `%USERPROFILE%\.dell\` for credential storage
- **Linux/macOS**: Uses `$HOME/.dell/` for credential storage
- **PowerShell Core**: Full compatibility across all supported PowerShell editions

## Performance Tips

### For Large Datasets
- Use CSV processing for bulk operations: `Get-ServiceEntitlements -csv -csvPath "assets.csv"`
- Leverage Azure Key Vault for enterprise credential management
- Consider using the `-passThrough` parameter when integrating with other automation tools

### Authentication Best Practices
- Use Azure Key Vault for production environments
- Regularly rotate API credentials
- Monitor API usage and rate limits

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss any changes.

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Make your changes and add tests
4. Run tests: `Invoke-Pester -Path .\Tests\`
5. Submit a pull request

## Troubleshooting

### Common Issues
- **Authentication Errors**: Verify your Dell API credentials are valid and haven't expired
- **Key Vault Access**: Ensure you have proper permissions to the Azure Key Vault
- **Network Connectivity**: Check firewall settings and internet connectivity to Dell's API endpoints
- **PowerShell Version**: Ensure you're running PowerShell 7.0 or later for full functionality

### Getting Support
- Review the [CHANGELOG.md](CHANGELOG.md) for recent updates
- Check [GitHub Issues](https://github.com/WFord26/DellServiceEntitlements/issues) for known problems
- Submit new issues with detailed error information and steps to reproduce

## Resources

- **Dell TechDirect**: [Get API Credentials](https://techdirect.dell.com/Portal/ApplyForAPIKeyWizard.aspx)
- **PowerShell Gallery**: [Module Page](https://www.powershellgallery.com/packages/DellServiceEntitlements)
- **GitHub Repository**: [Source Code](https://github.com/WFord26/DellServiceEntitlements)
- **Documentation**: [Function Reference](./Documentation/)

---

## License

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Contact & Support

**Author**: Managed Solution  
**Email**: [wford@managedsolution.com](mailto:wford@managedsolution.com)  
**Version**: 0.4.3  
**Last Updated**: June 24, 2025

For technical support, feature requests, or bug reports, please use the [GitHub Issues](https://github.com/WFord26/DellServiceEntitlements/issues) page.