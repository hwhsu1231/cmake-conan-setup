# Installation Guide for Windows

## 1. CMake

1.  Install CMake on your computer.

    -   You can run the [WinGet](https://github.com/microsoft/winget-cli) command:

        ```cmd
        winget install Kitware.CMake
        ```

    -   Or download installer from the [Releases](https://github.com/Kitware/CMake/releases) page.

2.  Append the directory of `cmake.exe` into env `PATH`. (If it doesn't)

## 2. Ninja

1.  Go to the [Releases](https://github.com/ninja-build/ninja/releases) page to download the zip file.

    - Extract the `ninja.exe` from the zip file.

    - Add the directory of `ninja.exe` into env `PATH`.
    
      > NOTE: Personally, I tend to put it in the bin folder of `cmake`.
    

## 3. C/C++ Compilers

### MSVC Compilers

1.  Download BuildTools, Community, or Professional...etc.

    -   You can either use [WinGet](https://github.com/microsoft/winget-cli) command to install.

        ```cmd
        ::Download Visual Studio 2019 BuildTools
        winget install Microsoft.VisualStudio.2019.BuildTools

        ::Download Visual Studio 2019 Community
        winget install Microsoft.VisualStudio.2019.Community
        ```

    -   Or go to the [Official Website](https://visualstudio.microsoft.com/vs/older-downloads/) page to download the installer.

2.  Click the following Workloads:

    -   Desktop development with C++
    -   Universal Windows Platform development
    -   Mobile development with C++

3.  Append the directory of `vcvarsall.bat` into env `PATH`.

    ```cmd
    ::Location of vcvarsall.bat.
    ::For example:
    C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build
    ```

### GCC/MinGW Compilers

1.  Install MSYS2 on Windows. 

    -   You can either use [WinGet](https://github.com/microsoft/winget-cli) command to install.

        ```cmd
        winget install msys2.msys2
        ```

    -   Or go to the [Official Website](https://www.msys2.org/) page to download the installer.

2.  Install MinGW x64 and MinGW x86 toolchain.

    ```bash
    # It is recommended to update the source before installation.
    pacman -Syu

    # Install x86 version of MinGW
    pacman -S mingw-w64-i686-toolchain
    
    # Install x64 version of MinGW
    pacman -S mingw-w64-x86_64-toolchain
    ```

### Clang/LLVM Compilers

1.  Install Clang/LLVM on your computer.

    -   You can either use [WinGet](https://github.com/microsoft/winget-cli) command to install.

        ```cmd
        ::Install x86 version of Clang/LLVM
        ::Default Install Location: C:\Program Files (x86)\LLVM
        winget install LLVM.LLVM -a x86

        ::Install x64 version of Clang/LLVM
        ::Default Install Location: C:\Program Files\LLVM
        winget install LLVM.LLVM -a x64
        ```

    -   Or go to the [Releases](https://github.com/llvm/llvm-project/releases) page to download the installer.

        - LLVM-xxx-win64.exe (for x64 compiler)
        - LLVM-xxx-win32.exe (for x86 compiler)
