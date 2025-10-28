$ErrorActionPreference = "Stop"

"Copying vcpkg.json..." | Write-Host
Copy-Item vcpkg.json ledger

"Copying CMakePresets.json..." | Write-Host
Copy-Item CMakePresets.json ledger

"Building ledger..." | Write-Host

Push-Location
cd ledger
cmake --preset release
if ($LASTEXITCODE) { exit $LASTEXITCODE }
cmake --build . --preset build-release
if ($LASTEXITCODE) { exit $LASTEXITCODE }
Pop-Location

if (Test-Path ledger.exe) {
  Remove-Item ledger.exe
}

cp ledger\Release\ledger.exe ledger.exe
