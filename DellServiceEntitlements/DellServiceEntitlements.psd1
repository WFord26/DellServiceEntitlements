@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'DellServiceEntitlements.psm1'

    # Version number of this module.
    ModuleVersion = '0.4.3'

    # Supported PSEditions
    CompatiblePSEditions = @('Core')

    # ID used to uniquely identify this module
    GUID = 'ce5906a5-7211-4f45-bd49-7e0691741347'

    # Author of this module
    Author = 'wford@managedsolution.com'

    # Company or vendor of this module
    CompanyName = 'Managed Solution'    # Copyright statement for this module
    Copyright = '(c) 2025 Managed Solution. All rights reserved.'

    # Description of the functionality provided by this module

    Description = 'PowerShell module for retrieving Dell warranty and service information with support for both local storage and Azure Key Vault integration. Note: Azure Key Vault functionality requires PowerShell 7.0 or later.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '7.0'
   
    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @('Az.Accounts', 'Az.KeyVault')

    # Functions to export from this module
    FunctionsToExport = @(
        'Get-ServiceEntitlements',
        'Set-DellKeyVaultSecrets',
        'Export-DellKeyVaultToXml'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Dell', 'Warranty', 'Service', 'ServiceTag', 'Azure', 'KeyVault')

            # ReleaseNotes of this module
            ReleaseNotes = '
            See the CHANGELOG.md file for a list of changes in each version.
            '

            # External dependent modules of this module
            ExternalModuleDependencies = @('Az.Accounts', 'Az.KeyVault')
        }
    }
}