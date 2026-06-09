param([Parameter(Mandatory=$true)][string]$Version)
& "$PSScriptRoot\compile.ps1" -Version $Version -DebugBuild
