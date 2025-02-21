# Changelog
All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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