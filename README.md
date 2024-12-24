# DellServiceEntitlements PowerShell Module

## Overview

The `DellServiceEntitlements` PowerShell module provides cmdlets to interact with Dell's service entitlement API. This module allows users to retrieve warranty and service information for Dell devices.


## Requirements

This module requires the following:

- PowerShell 5.1 or later
- An API key and secret provided by Dell. You can obtain this on the [Dell Tech Direct](https://techdirect.dell.com/Portal/ApplyForAPIKeyWizard.aspx).
- Internet connectivity to access Dell's service entitlement API.
- Administrator privileges to install the module.


## Installation

To install the `DellServiceEntitlements` module, follow these steps:

1. Download the latest release from the [GitHub releases page](https://github.com/WFord26/DellServiceEntitlements/releases).
2. Extract the downloaded file to a directory of your choice.
3. Open PowerShell and navigate to the directory where you extracted the files.
4. Run the following command from the file root to import the module:

```powershell
Import-Module -Name .\DellServiceEntitlements.psm1
```

## Usage

### Import the Module

Before using the cmdlets, import the module:

```powershell
Import-Module -name '/location/to/DellServiceEntitlements/DellServiceEntitlements/DellServiceEntitlements.psm1'
```

## Cmdlets

### Get-SerialNumber

Retrieves the Entitlement information depending on what parameters are passed to it. 

#### Parameters

- `-serviceTag` (String): The service tag of the Dell device.
- `-csv` (Boolean): Are you providing a CSV file or not.
- `-csvPath` (String): Location of the CSV file that you wish to run through. 

#### Example

**Searching for a specific service tag**

```powershell
Get-SerialNumber -serviceTag 24WPX42  

# Output                                                         
Token has expired, creating new Auth Token
Obtaining Dell token
Token created successfully
Service Tag provided, fetching warranty information

id                     : 691565644
serviceTag             : 24WPX42
orderBuid              : 11
shipDate               : 6/2/2015 5:00:00 AM
productCode            : DQ006
localChannel           : 08
productId              : networking-n2000-series
productLineDescription : DELL NETWORKING N-SERIES
productFamily          : all-products/enterprise-products/networking-products/switches/managed-campus-switches
systemDescription      : PowerSwitch N2000 Series
productLobDescription  : Dell Networking
countryCode            : US
duplicated             : False
invalid                : False
entitlements           : {@{itemNumber=966-3157; startDate=6/2/2015 5:00:00 AM; endDate=6/3/2016 4:59:59 AM;
                         entitlementType=INITIAL; serviceLevelCode=ND; serviceLevelDescription=Onsite Service After Remote  
                         Diagnosis (Consumer Customer)/ Next Business Day Onsite After Remote Diagnosis (for business       
                         Customer); serviceLevelGroup=5}, @{itemNumber=966-3183; startDate=6/2/2015 5:00:00 AM;
                         endDate=6/3/2018 4:59:59 AM; entitlementType=INITIAL; serviceLevelCode=SV;
                         serviceLevelDescription=Silver Support or ProSupport; serviceLevelGroup=8},
                         @{itemNumber=966-3154; startDate=6/2/2015 5:00:00 AM; endDate=10/18/2042 5:59:59 AM;
                         entitlementType=INITIAL; serviceLevelCode=LW; serviceLevelDescription=Limited Lifetime/Extended    
                         Warranty; serviceLevelGroup=11}, @{itemNumber=966-3159; startDate=6/3/2016 5:00:00 AM;
                         endDate=6/3/2018 4:59:59 AM; entitlementType=EXTENDED; serviceLevelCode=ND;
                         serviceLevelDescription=Onsite Service After Remote Diagnosis (Consumer Customer)/ Next Business   
                         Day Onsite After Remote Diagnosis (for business Customer); serviceLevelGroup=5}}

```

**Searching with system local service tag.** 

``` PowerShell
Get-SerialNumber

# Output

Service Tag provided, fetching warranty information


id                     : 2003316121
serviceTag             : 673W6S3
orderBuid              : 11
shipDate               : 2023-02-24T06:00:00Z
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
entitlements           : {@{itemNumber=997-8328; startDate=2023-02-24T06:00:00Z; endDate=2024-02-25T05:59:59.000001Z;
                         entitlementType=INITIAL; serviceLevelCode=ND; serviceLevelDescription=Onsite Service After
                         Remote Diagnosis (Consumer Customer)/ Next Business Day Onsite After Remote Diagnosis (for
                         business Customer); serviceLevelGroup=5}}

```

**Searching with a CSV**

```PowerShell
Get-ServiceEntitlements -csv -csvPath "C:\Temp\DellServiceTags.csv"
Warranty information for service tags exported to: DellWarranty-2024-12-24-16.49.36.csv

# If you don't provide a CSV

Get-ServiceEntitlements -csv
CSV file not found at path: Not Provided
Would you like us to create a new CSV file? (Y/N)
CSV template file created: $env:USERPROFILE\DellServiceTags.csv
Please fill in the ServiceTag column with the service tags of the Dell computers you wish to query.
Once complete, hit enter to continue.
Press Enter to continue...:
Warranty information for service tags exported to: DellWarranty-2024-12-24-16.49.36.csv
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