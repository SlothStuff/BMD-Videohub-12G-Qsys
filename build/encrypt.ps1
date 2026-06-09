# encrypt.ps1 - Encrypts the compiled .qplug into an encrypted .qplugx
# Requires the PluginEncryptionTool to be present at: tools/PluginEncryptionTool/release/
# Install: git clone https://github.com/qsys-plugins/PluginEncryptionTool.git tools/PluginEncryptionTool
# Usage: .\build\encrypt.ps1 -Version "1.0.0"

param(
  [Parameter(Mandatory=$true)][string]$Version
)

. "$PSScriptRoot\config.ps1"

$projectRoot = Split-Path -Parent $PSScriptRoot
$date        = Get-Date -Format "yyyy-MM-dd"
$distDir     = Join-Path (Join-Path $projectRoot "dist") "v$Version-$date"
$toolDir     = Join-Path (Join-Path (Join-Path $projectRoot "tools") "PluginEncryptionTool") "release"
$toolExe     = Join-Path $toolDir "plugin_tool_release.exe"

if (-not (Test-Path $toolExe)) {
  Write-Error "Encryption tool not found: $toolExe"
  Write-Error "From the project root, run:"
  Write-Error "  git clone https://github.com/qsys-plugins/PluginEncryptionTool.git tools/PluginEncryptionTool"
  exit 1
}

$qplugFile  = "${PluginName}_v${Version}.qplug"
$qplugxFile = "${PluginName}_v${Version}.qplugx"
$qplugPath  = Join-Path $distDir $qplugFile
$qplugxPath = Join-Path $distDir $qplugxFile

if (-not (Test-Path $qplugPath)) {
  Write-Error "Source not found: $qplugPath"
  Write-Error "Run compile.ps1 first."
  exit 1
}

# Run the tool from its own directory so sibling DLLs are discoverable
Push-Location $toolDir
try {
  & .\plugin_tool_release.exe encrypt "$qplugPath" "$qplugxPath"
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Encryption failed (exit code $LASTEXITCODE)"
    exit 1
  }
} finally {
  Pop-Location
}

Write-Host "  Encrypted: $qplugxPath"


