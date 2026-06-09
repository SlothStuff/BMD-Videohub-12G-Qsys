# setup-encryption-tool.ps1
# Clones the Q-SYS PluginEncryptionTool into tools/PluginEncryptionTool/
# Run once from the project root before your first encrypted build.
# Usage: .\tools\setup-encryption-tool.ps1

$toolDir = Join-Path $PSScriptRoot "PluginEncryptionTool"

if (Test-Path $toolDir) {
  Write-Host "PluginEncryptionTool already present at: $toolDir"
  Write-Host "To update, run: git -C `"$toolDir`" pull"
  exit 0
}

Write-Host "Cloning PluginEncryptionTool into $toolDir ..."
git clone https://github.com/qsys-plugins/PluginEncryptionTool.git "$toolDir"

if ($LASTEXITCODE -ne 0) {
  Write-Error "git clone failed. Make sure git is in your PATH and you have network access."
  exit 1
}

Write-Host ""
Write-Host "Done. Run .\build\build.ps1 to compile and encrypt your plugin."
