@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'Get-DellServiceEntitlements.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = '12345678-1234-1234-1234-123456789012'

    # Author of this module
    Author = 'Your Name'

    # Company or vendor of this module
    CompanyName = 'Your Company'

    # Description of the functionality provided by this module
    Description = 'A module to retrieve Dell service entitlements and update ConnectWise Manage configurations.'

    # Functions to export from this module
    FunctionsToExport = @(
        'Get-DellToken',
        'Save-Credential',
        'Get-SavedCredential',
        'Test-DellToken',
        'Get-DellWarranty',
        'Get-SerialNumber'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{

    }
}