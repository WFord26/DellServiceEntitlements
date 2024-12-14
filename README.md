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

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Contact

For any questions or issues, please contact [wford@managedsolution.com](mailto:wford@managedsolution.com).