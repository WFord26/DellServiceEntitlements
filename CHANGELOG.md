# Changelog
All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.3] - 2025-06-24

### Updated
- Enhanced documentation for all public functions with detailed parameter descriptions and examples:
  - `Get-ServiceEntitlements` - Added comprehensive parameter documentation and usage examples
  - `Set-DellKeyVaultSecrets` - Improved parameter descriptions and added practical examples
  - `Export-DellKeyVaultToXml` - Enhanced function documentation with detailed parameter descriptions and additional notes
- Updated module version to 0.4.3
- Updated copyright year to 2025 in module manifest
- Improved Pester test structure and reliability:
  - Enhanced test organization with proper module scoping
  - Added comprehensive mocking for Azure Key Vault functionality
  - Improved test coverage for error handling scenarios
  - Fixed test path resolution for better cross-platform compatibility

### Added
- Added `passThrough` parameter to `Get-ServiceEntitlements` function for better integration with other scripts
- Enhanced InModuleScope testing for better isolation of unit tests

## [0.4.2] - 2025-03-11

### Updated
- Default output formatting for `Get-ServiceEntitlements`
- Added passthrough switch to allow passing hashtable to other scripts

## [0.4.1] - 2025-03-11
### Updated
- Improved authentication token management with automatic renewal
- Optimized CSV processing for large datasets
- Updated documentation with performance tuning recommendations

### Fixed
- Fixed thread safety issues in token refresh operations
- Addressed authentication context sharing in parallel operations
- Improved error handling for network timeouts and transient failures
- Enhanced reliability of credential storage access

## [0.4.0] - 2025-03-11
### Added
- Added `Set-UserProfilePath.ps1` to set the user profile path based on the OS.
- Added `Get-ServiceEntitlements.ps1` to retrieve the serial number and warranty information for Dell computers.
- Added comprehensive documentation for all functions including markdown files for:
  - `Get-ServiceEntitlements`
  - `Set-DellKeyVaultSecrets` 
  - `Export-DellKeyVaultToXml`
- Expanded README with detailed usage examples and authentication methods

### Updated
- Updated `Get-DellApiKey.ps1` to set environment variables for API key and client secret.
- Updated `Grant-DellToken.ps1` to save the token details to an XML file.
- Updated `Test-DellToken.ps1` to check the validity of the Dell API authentication token and generate a new one if necessary.
- Updated `Get-DellWarranty.ps1` to retrieve Dell warranty information for a given service tag.
- Improved cross-platform support with better path handling for Windows, Linux, and macOS

### Fixed
- Fixed token refresh mechanism to ensure continuous API access
- Improved error handling in CSV processing
- Enhanced credential validation routines

## [0.3.0] - 2025-02-19
### Added
- Azure Key Vault integration for secure credential storage (requires PowerShell 7.0+)
- New functions for Key Vault operations:
  - `Set-DellKeyVaultSecrets` for storing credentials in Key Vault
  - `Get-DellKeyVaultSecrets` for retrieving credentials from Key Vault
  - `Update-DellKeyVaultToken` for managing auth tokens in Key Vault
  - `Export-DellKeyVaultToXml` for exporting Key Vault credentials to local storage
  - `Test-PowerShellVersion` for validating PowerShell version requirements
- New parameters for Key Vault support in existing functions:
  - Added `-UseKeyVault` switch
  - Added `-KeyVaultName` parameter
  - Added `-ApiKeySecretName` parameter
  - Added `-ClientSecretName` parameter
  - Added `-AuthTokenSecretName` parameter

### Changed
- Updated minimum PowerShell version to 7.0 for Azure Key Vault functionality
- Modified module manifest to reflect PowerShell Core requirement for Azure features
- Updated module description and requirements documentation
- Improved error handling and version validation for Azure features

### Fixed
- Token expiration handling in Key Vault storage
- Error handling for Azure authentication failures
- Credential export format consistency

## [0.2.0] - 2024-12-24
### Added 
- Added metadata properties to `Get-ServiceEntitlements.ps1` script
- Added `Test-ServiceTagCSV.ps1` to make sure CSV file exists
- Added `New-DellTemplateTagCSV.ps1` to create CSV file that user can pass serviceTags to
- Added error handling and updated documentation

### Updated
- Renamed `Get-SerialNumber` to `Get-ServiceEntitlements` to be less ambiguous

## [0.1.0] - 2024-12-19
### Added
- Initial release
- Public Functions:
  - Get-DellWarranty
  - Get-SerialNumber
- Private Functions:
  - Get-DellApiKey
  - Grant-DellToken