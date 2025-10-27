# Build ledger on Windows
## Overview and versions
Three ways to build ledger on Windows are presented in this directory. All the steps are essentially the same in all the three, the difference is how, when and where they are executed.

- The easy way is just download the binary from the Releases page in this GitHub repository. This binary is built with [GitHub Actions](https://github.com/features/actions) on GitHub hardware and software. 
- You can build the binary yourself by installing the prerequisites, cloning the repository and running a provided PowerShell script.
- The hard way is to run all the commands from the command line - this way you will know exactly what you are doing.

The steps to compile ledger that the three ways mentioned above execute are:

1. Install [Visual Studio 2022](https://www.visualstudio.com/downloads/). GitHub Actions use Visual Studio Enterprise. The PowerShell script and the Hard Way were tested on the Community Edition, but should work with other editions too.
2. Install [CMake](https://cmake.org/download/) 4.1.2 was tested for manual installs. Actions use their own current version.
3. Clone [this repository](https://github.com/andrewsav/ledger-windows-build)
4. Clone [vcpkg](https://github.com/microsoft/vcpkg.git)
5. Install boost, mpfr and icu
7. Build [ledger](http://ledger-cli.org/) (v3.4.1)

## Automated Build with GitHub Actions

This section is intended for repository maintainers, and those who would like to educate themselves. If you just want the binary, head to the Releases page and be done with it.

GitHub provides some software and libraries in its Actions environment, notably Visual Studio and CMake. It's nice that you do not need to download and install those, but it also means that you cannot choose versions, you get what is already there. Since GitHub constantly updates their environment templates it can potentially break the automated build in future.

At the moment of writing, the repository contains a single actions:

- [build.yaml](.github/workflows/build.yaml) - this action is built automatically upon tagging a commit (see below). It uses the same [build.ps1](build.ps1) script as the manual process uses

In order to kick off a new releases follow these steps:

- Clone the repository with `--recursive` flag

- Update submodules:

  ```powershell
  cd ledger
  git checkout <tag>
  ```
  
  *<u>Note</u>, that you have to replace `<tag>` above with tag, branch or commit number of the ledger repository commit you would like to build.*
  
  *<u>Note</u>, that the above only works on a fresh `clone`, if you cloned this repo some time ago you will also have to `git pull` in the submodule directory.*

  *<u>Note</u>, that other commits of the submodule than the one in this repository may require a different build process.*

- Commit your changes, push the commit, tag it and push the tag:

  ```bash
  git commit -m "Updating to <tag>" -a
  git push
  git tag <tag>
  git push origin --tags
  ```

At this point, the GitHub Actions will kick in and you will be able to watch it build, on the Actions tab of this repo. When the build succeeds a release will be created automatically corresponding to the tag name you specified above.

*<u>Note on forks:</u> when this repo is forked, GitHub will ask you whether or not you would like to enable Actions. Generally Actions are free for public repositories, but it's your responsibility to check if this is so in your case.*

## Prerequisites for manual build

These instructions were tested on **Windows 11**. They may also work on other flavors of Windows as long the software below is installed. Visual Studio 2022 cannot be installed on some older versions of Windows.

- [Download](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community&channel=Release&version=VS2022&source=VSLandingPage&passive=false&cid=2030), install Visual Studio Community 2022. When installing make sure to install "Desktop development with C++" payload and "Git for Windows" component. Make sure that `git` is available on your `PATH`. 

- [Download](https://github.com/Kitware/CMake/releases/download/v3.27.7/cmake-3.27.7-windows-x86_64.msi) and install CMake; adding it to the `PATH`

- [Download](https://www.7-zip.org/download.html), install 7zip, and make sure it's on `PATH`. `7z` boost archive is expanded much faster than `zip`

- Clone the repository recursively:

  ```powershell
  git clone https://github.com/andrewsav/ledger-windows-build --recursive
  ```

  *<u>Note:</u> Use a different URL above if you are using a fork of the original instructions.*

## Using PowerShell script to build ledger

Open `Developer PowerShell for VS 2022` and make sure that the current folder is the root of this recursively cloned repo. Run:

```powershell
.\build.ps1
```

The build time can be an hour or more, depending on your machine. If there was no errors you should end up with `ledger.exe` in your current folder, when the build finishes.

## Building Ledger the Hard Way

*In the steps below 'at the command prompt' means use the `Developer PowerShell for VS 2022` to execute the commands listed, starting with the current directory as the repository root.*

At the command prompt clone the vcpkg repository:

```powershell
git clone https://github.com/microsoft/vcpkg.git
```

At the command prompt run the following to build build `boost`, `mpfr` and `icu`:

    cd vcpkg
    ./bootstrap-vcpkg.bat
    ./vcpkg install boost:x64-windows-static mpfr:x64-windows-static icu:x64-windows-static
    cd ..

At the command prompt run the following to build ``ledger.exe``:

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
    msbuild /p:Configuration=Release src\ledger.vcxproj
    cd ..
    cp ledger\Release\ledger.exe ledger.exe

You should now have `ledger.exe` at your current folder in the root of the cloned repository.

## Notes

- These instructions were initially derived from the [wiki page](https://github.com/ledger/ledger/wiki/Build-instructions-for-Microsoft-Visual-C---11-(2012)) by Tim Crews, however over the years they drifted quite apart.
- Boost is time consuming to build, especially as we have to build all of the libraries to build the unit test framework; the other libraries can be built at the same time.

## Licenses

### Boost

    Distributed under the Boost Software License, Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

### MPFR

    Copyright 2000-2025 Free Software Foundation, Inc.
    Contributed by the AriC and Caramba projects, INRIA.
    
    This file is part of the GNU MPFR Library.
    
    The GNU MPFR Library is free software; you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation; either version 3 of the License, or (at your
    option) any later version.
    
    The GNU MPFR Library is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
    License for more details.
    
    You should have received a copy of the GNU Lesser General Public License
    along with the GNU MPFR Library; see the file COPYING.LESSER.  If not, see
    https://www.gnu.org/licenses/ or write to the Free Software Foundation, Inc.,
    51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.

### Ledger

Copyright (c) 2003-2025, John Wiegley. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of New Artisans LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
