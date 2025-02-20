# Changelog
All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0-beta] - 2025-02-19
### Added
- Azure Key Vault integration for secure credential storage
- New functions for Key Vault operations:
  - `Set-DellKeyVaultSecrets` for storing credentials in Key Vault
  - `Get-DellKeyVaultSecrets` for retrieving credentials from Key Vault
  - `Update-DellKeyVaultToken` for managing auth tokens in Key Vault
- New parameters for Key Vault support in existing functions:
  - Added `-UseKeyVault` switch
  - Added `-KeyVaultName` parameter
  - Added `-ApiKeySecretName` parameter
  - Added `-ClientSecretName` parameter
  - Added `-AuthTokenSecretName` parameter
### Updated
- Modified `Get-ServiceEntitlements.ps1` to support Key Vault authentication
- Updated `Get-DellWarranty.ps1` with improved token management
- Enhanced `Get-DellApiKey.ps1` to handle both local and Key Vault storage
- Improved `Test-DellToken.ps1` with better error handling and token validation
- Updated `Grant-DellToken.ps1` with more robust token creation and storage

## [0.2.0] - 2024-12-24
### Added 
- Added metadata properties to `Get-ServiceEntitlements.ps1` script.
- Added `Test-ServiceTagCSV.ps1` to make sure CSV file exists. 
- Added `New-DellTemplateTagCSV.ps1` to create CSV file that user can pass serviceTags to.
- Added error handling and updated.

### Updated
- Renamed `Get-SerialNumber` to `Get-ServiceEntitlements` to be less ambiguous.

## [0.1.0] - 2024-12-19
### Added
- Initial release
- Public Functions:
  - Get-DellWarranty
  - Get-SerialNumber
- Private Functions:
  - Get-DellApiKey
  - Grant-DellToken
  - Import-SavedCredential
  - Save-DellCredential
  - Test-DellToken
- Basic Dell warranty lookup functionality
- Dell API authentication handling
- Credential management features

[Unreleased]: https://github.com/WFord26/DellServiceEntitlements/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/WFord26/DellServiceEntitlements/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/WFord26/DellServiceEntitlements/releases/tag/v0.2.0
[0.1.0]: https://github.com/WFord26/DellServiceEntitlements/releases/tag/v0.1.0