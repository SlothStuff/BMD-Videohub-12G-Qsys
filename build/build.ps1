# build.ps1 - Master build script for Videohub12G
# Usage:
#   .\build\build.ps1             Standard build (compile + encrypt)
#   .\build\build.ps1 -DebugBuild Debug build only (no encryption)
#   .\build\build.ps1 -NoEncrypt  Compile only, skip encryption

param(
  [switch]$DebugBuild,
  [switch]$NoEncrypt
)

. "$PSScriptRoot\config.ps1"

$projectRoot = Split-Path -Parent $PSScriptRoot
$versionFile = Join-Path $projectRoot "VERSION"

if (-not (Test-Path $versionFile)) {
  Write-Error "VERSION file not found at: $versionFile"
  exit 1
}

$currentVersion = (Get-Content $versionFile -Raw -Encoding UTF8).Trim()

Write-Host ""
Write-Host "==================================================="
Write-Host "  $PluginName Plugin Build"
Write-Host "==================================================="
Write-Host "  Current version: $currentVersion"

$newVersion = Read-Host "  Enter new version (press Enter to keep $currentVersion)"

if ([string]::IsNullOrWhiteSpace($newVersion)) {
  $newVersion = $currentVersion
} else {
  Set-Content -Path $versionFile -Value $newVersion -Encoding UTF8 -NoNewline
  Write-Host "  Updated VERSION -> $newVersion"
}

Write-Host ""

if ($DebugBuild) {
  Write-Host "--- Debug Build ---"
  & "$PSScriptRoot\compile.ps1" -Version $newVersion -DebugBuild
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  Write-Host ""
  Write-Host "Debug build complete. No encryption for debug builds."
} else {
  Write-Host "--- Compiling ---"
  & "$PSScriptRoot\compile.ps1" -Version $newVersion
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

  if (-not $NoEncrypt) {
    Write-Host ""
    Write-Host "--- Encrypting ---"
    & "$PSScriptRoot\encrypt.ps1" -Version $newVersion
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  }
}

Write-Host ""
Write-Host "==================================================="
Write-Host "  Build complete!"
Write-Host "==================================================="
