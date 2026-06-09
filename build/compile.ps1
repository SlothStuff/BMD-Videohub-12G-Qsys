# compile.ps1 - Expands #include directives and compiles plugin.lua -> .qplug
# Called by build.ps1; can also be run directly.
# Usage:
#   .\build\compile.ps1 -Version "1.0.0"
#   .\build\compile.ps1 -Version "1.0.0" -DebugBuild

param(
  [Parameter(Mandatory=$true)][string]$Version,
  [switch]$DebugBuild
)

. "$PSScriptRoot\config.ps1"

$projectRoot = Split-Path -Parent $PSScriptRoot
$srcDir      = Join-Path $projectRoot "src"
$date        = Get-Date -Format "yyyy-MM-dd"
$distFolder  = "v$Version-$date"
$distDir     = Join-Path (Join-Path $projectRoot "dist") $distFolder
$guidFile    = Join-Path $projectRoot ".plugin-guid"

$entryFile = if ($DebugBuild) { "plugin-debug.lua" } else { "plugin.lua" }
$entryPath = Join-Path $srcDir $entryFile

if (-not (Test-Path $entryPath)) {
  Write-Error "Entry point not found: $entryPath"
  exit 1
}

New-Item -ItemType Directory -Force -Path $distDir | Out-Null

function Expand-Includes {
  param([string]$Content, [string]$BaseDir)

  $pattern = '--\[\[[ \t]*#include[ \t]+"([^"]+)"[ \t]*\]\]'
  $match   = [regex]::Match($Content, $pattern)

  while ($match.Success) {
    $relPath = $match.Groups[1].Value
    $absPath = [System.IO.Path]::GetFullPath((Join-Path $BaseDir $relPath))

    if (-not (Test-Path $absPath)) {
      Write-Error "Include not found: $absPath"
      Write-Error "  Referenced from: $BaseDir"
      exit 1
    }

    $includeDir     = Split-Path -Parent $absPath
    $includeContent = Get-Content $absPath -Raw -Encoding UTF8
    $expanded       = Expand-Includes -Content $includeContent -BaseDir $includeDir

    $Content = $Content.Substring(0, $match.Index) `
             + $expanded `
             + $Content.Substring($match.Index + $match.Length)

    $match = [regex]::Match($Content, $pattern)
  }

  return $Content
}

if (Test-Path $guidFile) {
  $pluginGuid = (Get-Content $guidFile -Raw -Encoding UTF8).Trim()
  Write-Host "  Plugin GUID: $pluginGuid"
} else {
  $pluginGuid = [System.Guid]::NewGuid().ToString()
  Set-Content -Path $guidFile -Value $pluginGuid -Encoding UTF8 -NoNewline
  Write-Host "  Generated Plugin GUID: $pluginGuid"
  Write-Host "  Saved to .plugin-guid -- commit this file to preserve plugin identity."
}

$activeGuid = if ($DebugBuild) { "$pluginGuid-debug" } else { $pluginGuid }

Write-Host "  Entry:  $entryFile"
$content  = Get-Content $entryPath -Raw -Encoding UTF8
$compiled = Expand-Includes -Content $content -BaseDir $srcDir

$compiled = $compiled -replace '\{\{VERSION\}\}', $Version
$compiled = $compiled -replace '<guid>', $activeGuid

$suffix     = if ($DebugBuild) { "_debug" } else { "" }
$outputFile = "${PluginName}_v${Version}${suffix}.qplug"
$outputPath = Join-Path $distDir $outputFile

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outputPath, $compiled, $utf8NoBom)

Write-Host "  Output: $outputPath"

