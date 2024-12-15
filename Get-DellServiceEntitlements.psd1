@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'Get-DellServiceEntitlements.psm1'

    # Version number of this module.
    ModuleVersion = '0.0.2'

    # ID used to uniquely identify this module
    GUID = '16ae8a67-ac4d-4202-9563-348d08fc3ebb'

    # Author of this module
    Author = 'William Ford'

    # Company or vendor of this module
    CompanyName = 'Managed Solution'

    # Description of the functionality provided by this module
    Description = 'A module to retrieve Dell service entitlements and update ConnectWise Manage configurations.'

    # Functions to export from this module
    FunctionsToExport = @(
        'Grant-DellToken',
        'Get-DellApiKeys',
        'Save-Credential',
        'Import-SavedCredential',
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