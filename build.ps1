$ErrorActionPreference = "Stop"

"Cloning vcpkg..." | Write-Host
git clone https://github.com/microsoft/vcpkg.git
if ($LASTEXITCODE) { exit $LASTEXITCODE }

"Running vcpkg..." | Write-Host
Push-Location
cd vcpkg
./bootstrap-vcpkg.bat
if ($LASTEXITCODE) { exit $LASTEXITCODE }
./vcpkg install boost:x64-windows-static mpfr:x64-windows-static icu:x64-windows-static
if ($LASTEXITCODE) { exit $LASTEXITCODE }
Pop-Location

"Building ledger..." | Write-Host

Push-Location
cd ledger
cmake `
  '-DCMAKE_BUILD_TYPE:STRING=Release' `
  '-DBUILD_LIBRARY=OFF' `
  '-DBUILD_DOCS:BOOL=0' `
  '-DHAVE_GETPWUID:BOOL=0' `
  '-DHAVE_GETPWNAM:BOOL=0' `
  '-DHAVE_IOCTL:BOOL=0' `
  '-DHAVE_ISATTY:BOOL=0' `
  '-DCMAKE_TOOLCHAIN_FILE=..\vcpkg\scripts\buildsystems\vcpkg.cmake' `
  '-DVCPKG_TARGET_TRIPLET=x64-windows-static' `
  '-DCMAKE_CXX_STANDARD=20' `
  '-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded' `
  '-DCMAKE_CXX_FLAGS_RELEASE:STRING=/Zi /Ob0 /Od /Zc:__cplusplus /D LITTLE_ENDIAN=1234 /D BIG_ENDIAN=4321 /D BYTE_ORDER=LITTLE_ENDIAN' `
  -B . `
  -A x64 `
  -G "Visual Studio 17"
if ($LASTEXITCODE) { exit $LASTEXITCODE }
msbuild /p:Configuration=Release src\ledger.vcxproj
if ($LASTEXITCODE) { exit $LASTEXITCODE }
Pop-Location

if (Test-Path ledger.exe) {
  Remove-Item ledger.exe
}

cp ledger\Release\ledger.exe ledger.exe
