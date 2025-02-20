@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'DellServiceEntitlements.psm1'

    # Version number of this module.
    ModuleVersion = '0.3.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = 'ce5906a5-7211-4f45-bd49-7e0691741347'

    # Author of this module
    Author = 'wford@managedsolution.com'

    # Company or vendor of this module
    CompanyName = 'Managed Solution'

    # Copyright statement for this module
    Copyright = '(c) 2024 Managed Solution. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PowerShell module for retrieving Dell warranty and service information with support for both local storage and Azure Key Vault integration.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

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

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Get-ServiceEntitlements',
        'Set-DellKeyVaultSecrets',
        'Get-DellKeyVaultSecrets',
        'Update-DellKeyVaultToken'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    FileList = @(
        'DellServiceEntitlements.psm1',
        'Get-ServiceEntitlements.ps1',
        'Get-DellApiKey.ps1',
        'Get-DellWarranty.ps1',
        'Grant-DellToken.ps1',
        'Import-SavedCredential.ps1',
        'Save-DellCredential.ps1',
        'Set-UserProfilePath.ps1',
        'Test-DellToken.ps1',
        'Test-ServiceTagCSV.ps1',
        'New-DellTemplateCSV.ps1',
        'Set-DellKeyVaultSecrets.ps1',
        'Get-DellKeyVaultSecrets.ps1',
        'Update-DellKeyVaultToken.ps1'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Dell', 'Warranty', 'Service', 'ServiceTag', 'Azure', 'KeyVault')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/WFord26/DellServiceEntitlements/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/WFord26/DellServiceEntitlements'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = '
            Version 0.3.0:
            - Added Azure Key Vault integration for secure credential storage
            - Added new functions for Key Vault operations
            - Added Key Vault support to existing functions
            - Improved token management and error handling
            
            Version 0.2.0:
            - Added metadata properties
            - Added CSV file handling
            - Improved error handling
            
            Version 0.1.0:
            - Initial release
            - Basic Dell warranty lookup functionality
            - Local credential management
            '

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            ExternalModuleDependencies = @('Az.Accounts', 'Az.KeyVault')
        } # End of PSData hashtable
    } # End of PrivateData hashtable

    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}