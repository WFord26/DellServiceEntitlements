$ModuleName = '.\DellServiceEntitlements\DellServiceEntitlements.psm1'
Import-Module -name $ModuleName -Force -PassThru | Out-Null
$commandList = Get-Command -Module $ModuleName -CommandType Function, Cmdlet

Write-Output 'Calculating fingerprint'
$fingerprint = foreach ( $command in $commandList )
{
    foreach ( $parameter in $command.parameters.keys )
    {
        '{0}:{1}' -f $command.name, $command.parameters[$parameter].Name
        $command.parameters[$parameter].aliases | 
            Foreach-Object { '{0}:{1}' -f $command.name, $_}
    }
}

# Include private functions in the fingerprint
$privateFunctions = Get-ChildItem -Path (Join-Path (Split-Path $ModuleName) 'Private') -Filter '*.ps1' -Recurse
foreach ($privateFunction in $privateFunctions) {
    $functionName = (Get-Content $privateFunction | Select-String -Pattern 'function\s+([^\s{]+)' -AllMatches).Matches.Groups[1].Value
    if ($functionName) {
        $fingerprint += $functionName
    }
}
if ( Test-Path .\Build\fingerprint )
{
    $oldFingerprint = Get-Content .\Build\fingerprint
}

$bumpVersionType = 'Patch'
'Detecting new features'
$fingerprint | Where {$_ -notin $oldFingerprint } | 
    ForEach-Object {$bumpVersionType = 'Minor'; "  $_"}
'Detecting breaking changes'
$oldFingerprint | Where {$_ -notin $fingerprint } | 
    ForEach-Object {$bumpVersionType = 'Major'; "  $_"}

Set-Content -Path .\Build\fingerprint -Value $fingerprint
$ManifestPath = '.\DellServiceEntitlements\DellServiceEntitlements.psd1'
Step-ModuleVersion -Path $ManifestPath -By $bumpVersionType