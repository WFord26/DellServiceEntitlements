$ModuleName = '.\DellServiceEntitlements\DellServiceEntitlements.psm1'
Import-Module -name '.\DellServiceEntitlements\DellServiceEntitlements.psm1'
$commandList = Get-Command -Module $ModuleName
Remove-Module $ModuleName

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
if ( Test-Path .\fingerprint )
{
    $oldFingerprint = Get-Content .\fingerprint
}

$bumpVersionType = 'Patch'
'Detecting new features'
$fingerprint | Where {$_ -notin $oldFingerprint } | 
    ForEach-Object {$bumpVersionType = 'Minor'; "  $_"}
'Detecting breaking changes'
$oldFingerprint | Where {$_ -notin $fingerprint } | 
    ForEach-Object {$bumpVersionType = 'Major'; "  $_"}

Set-Content -Path .\fingerprint -Value $fingerprint
$ManifestPath = '.\DellServiceEntitlements\DellServiceEntitlements.psd1'
Step-ModuleVersion -Path $ManifestPath -By $bumpVersionType