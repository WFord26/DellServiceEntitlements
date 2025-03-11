@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'DellServiceEntitlements.psm1'

    # Version number of this module.
    ModuleVersion = '0.2.0'

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
        'Get-ServiceEntitlements'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
       
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags         = @('Managed Solution', 'Dell', 'Service Entitlements', 'REST', 'API')

        # A URL to the license for this module.
        LicenseUri   = 'https://github.com/WFord26/DellServiceEntitlements/blob/main/license'

        # A URL to the main website for this project.
        ProjectUri   = 'https://github.com/WFord26/DellServiceEntitlements' 

    }
}