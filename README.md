# DellServiceEntitlements PowerShell Module

## Overview

The `DellServiceEntitlements` PowerShell module provides cmdlets to interact with Dell's service entitlement API. This module allows users to retrieve warranty and service information for Dell devices.

## Installation

To install the `DellServiceEntitlements` module, run the following command:

```powershell
Install-Module -Name DellServiceEntitlements
```

## Usage

### Import the Module

Before using the cmdlets, import the module:

```powershell
Import-Module DellServiceEntitlements
```

### Retrieve Service Entitlements

To retrieve service entitlements for a Dell device, use the `Get-DellServiceEntitlement` cmdlet:

```powershell
Get-DellServiceEntitlement -ServiceTag <ServiceTag>
```

Replace `<ServiceTag>` with the actual service tag of the Dell device.

## Cmdlets

### Get-DellServiceEntitlement

Retrieves the service entitlement information for a specified Dell device.

#### Parameters

- `-ServiceTag` (String): The service tag of the Dell device.

#### Example

```powershell
Get-DellServiceEntitlement -ServiceTag ABCD123
```

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss any changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or issues, please contact [wford@managedsolution.com](mailto:wford@managedsolution.com).