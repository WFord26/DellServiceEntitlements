# Changelog
All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[0.1.0]: https://github.com/WFord26/DellServiceEntitlements/releases/tag/v0.1.0