#!/usr/bin/env pwsh
param(
    $Source,
    $CMakeArgs="-DCMAKE_BUILD_TYPE=Debug",
    $ProgramArgs="",
    [switch]$FullLeakCheck,
    [switch]$Help)

#----------------------------------------------------------------
# Helper functions
#----------------------------------------------------------------

function Print-Header {
    Write-Host " ______   _______  _______  _        _______  _______ _________ _______  _______  ______  "
    Write-Host "(  __  \ (  ___  )(  ____ \| \    /\(  ____ \(  ____ )\__   __// ___   )(  ____ \(  __  \ "
    Write-Host "| (  \  )| (   ) || (    \/|  \  / /| (    \/| (    )|   ) (   \/   )  || (    \/| (  \  )"
    Write-Host "| |   ) || |   | || |      |  (_/ / | (__    | (____)|   | |       /   )| (__    | |   ) |"
    Write-Host "| |   | || |   | || |      |   _ (  |  __)   |     __)   | |      /   / |  __)   | |   | |"
    Write-Host "| |   ) || |   | || |      |  ( \ \ | (      | (\ (      | |     /   /  | (      | |   ) |"
    Write-Host "| (__/  )| (___) || (____/\|  /  \ \| (____/\| ) \ \_____) (___ /   (_/\| (____/\| (__/  )"
    Write-Host "(______/ (_______)(_______/|_/    \/(_______/|/   \__/\_______/(_______/(_______/(______/ "
    Write-Host "                                                                                          "
    Write-Host "          _______  _        _______  _______ _________ _        ______  "
    Write-Host "|\     /|(  ___  )( \      (  ____ \(  ____ )\__   __/( (    /|(  __  \ "
    Write-Host "| )   ( || (   ) || (      | (    \/| (    )|   ) (   |  \  ( || (  \  )"
    Write-Host "| |   | || (___) || |      | |      | (____)|   | |   |   \ | || |   ) |"
    Write-Host "( (   ) )|  ___  || |      | | ____ |     __)   | |   | (\ \) || |   | |"
    Write-Host " \ \_/ / | (   ) || |      | | \_  )| (\ (      | |   | | \   || |   ) |"
    Write-Host "  \   /  | )   ( || (____/\| (___) || ) \ \_____) (___| )  \  || (__/  )"
    Write-Host "   \_/   |/     \|(_______/(_______)|/   \__/\_______/|/    )_)(______/ "
    Write-Host "                                                                        "
}

function Print-Help {
    Print-Header
    Write-Host @"

Usage: ./valgrind.ps1 [--Source <directory>][--ProgramArgs <args>][--CMakeArgs <args>][--FullLeakCheck]
Options:
    --Source            The source directory to compile and
                        run valgrind against.
    --ProgramArgs       Arguments to pass to the program.
    --CMakeArgs         A string of arguments to send to CMake.
    --FullLeakCheck     If set, valgrind will run with full
                        leak check flags.

Examples:
    *) ./valgrind.ps1 --ProgramArgs "arg1 arg2"
    *) ./valgrind.ps1 --FullLeakCheck --Source ./example
    *) ./valgrind.ps1 --Source "/Users/yahavbar/CLionProjects/c-ex1" --ProgramArgs "5 /path/to/input.txt" --FullLeakCheck
    *) ./valgrind.ps1 --CMakeArgs "-DCMAKE_BUILD_TYPE=Release"
"@
}

#----------------------------------------------------------------
# Setup
#----------------------------------------------------------------

if ($Help) {
    Print-Help
    exit 1
}

if (!$Source) {
    $Source = Get-Location
}

# Resolve the path
$Source = Resolve-Path $Source

#----------------------------------------------------------------
# Header
#----------------------------------------------------------------

Print-Header
Write-Host @"
Running valgrind with the following configuration:
- Source Directory:     $Source
- CMake Arguments:      $CMakeArgs
- Program Arguments:    $ProgramArgs
----------------------------------------------------------------
"@

#----------------------------------------------------------------
# Make sure that we have a CMakeLists.txt
#----------------------------------------------------------------
if (!(Test-Path "$Source/CMakeLists.txt")) {
    Write-Error "Could not find CMakeLists.txt in $Source"
    Write-Error "Plese create a CMakeLists.txt file or re-target your source directory, using --Source, to a directory with CMakeLists.txt."
    exit 1
}

#----------------------------------------------------------------
# Setup valgrind flags
#----------------------------------------------------------------
if ($FullLeakCheck) {
    $ValgrindArgs = "--leak-check=full --leak-resolution=med --track-origins=yes"
} else {
    $ValgrindArgs = ""
}

# Other non-configurable constants
$DockerImageName='hujilabcc/valgrind'
$ExecutableName='a.out'

#----------------------------------------------------------------
# Run docker
#----------------------------------------------------------------

docker run -v ${Source}:/input:ro -i hujilabcc/valgrind /bin/sh -c "cmake $CMakeArgs /input/ && make && valgrind $ValgrindArgs ./$ExecutableName $ProgramArgs"