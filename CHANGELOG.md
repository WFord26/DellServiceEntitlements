# Changelog
All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Added `Set-UserProfilePath.ps1` to set the user profile path based on the OS.
- Added `Get-ServiceEntitlements.ps1` to retrieve the serial number and warranty information for Dell computers.

### Updated
- Updated `Get-DellApiKey.ps1` to set environment variables for API key and client secret.
- Updated `Grant-DellToken.ps1` to save the token details to an XML file.
- Updated `Test-DellToken.ps1` to check the validity of the Dell API authentication token and generate a new one if necessary.
- Updated `Get-DellWarranty.ps1` to retrieve Dell warranty information for a given service tag.


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

[0.2.0]: https://github.com/WFord26/DellServiceEntitlements/releases/tag/v0.2.0
[0.1.0]: https://github.com/WFord26/DellServiceEntitlements/releases/tag/v0.1.0