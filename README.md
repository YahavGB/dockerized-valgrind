# Dockerized Valgrind
## Disclaimer
This tool was developed for the course "Programming Workshop in C and C++", offered by the Hebrew University. Students, beware: this is not a replacement for proper valgrind testing on the school ("aquarium") computers.
It should just be an aid for you when writing the programs.

## Introduction
This repository provides an alternative method to test your programs for memory leaks, using Valgrind, __without installing it on your PC "directly"__.

__Reminder:__ [Valgrind](https://valgrind.org/) is an instrumentation framework for building dynamic analysis tools. There are Valgrind tools that can automatically detect many memory management and threading bugs, and profile your programs in detail. 

At the course, we require that every exercise will be leak-prune, and thus memory lead will lead to points reduction. Thus, the usage of valgrind is required to get full mark grades.

While you can follow the instructions published online or given at class to install Valgrind, it is not a trivial action, and sometimes (macOS) it's not possible without modification of Valgrinds source code.

## Requirements
This tutorial is relevant for both Windows, macOS and Linux based operating system - so everyone can use it. Hooray! 🎉

To be able to follow this tutorial, make sure that you have installed on your computer:


* __git__:
    * __Windows__: [You can find detailed installation guide on MSDN (Microsoft Developer Network) site](https://docs.microsoft.com/en-us/azure/devops/learn/git/install-and-set-up-git). Generally, it can be downloaded from multiple sources, [such as this one](https://git-scm.com/download/win).
    * __macOS__: macOS 10.9 (Mavericks) or higher will install Git the first time you try to run Git from the Terminal. Alternatively, you can install git [using Homebrew](http://brew.sh/).
    * __Linux__: You can install Git on Linux using the package manager that was provided in your Linux distribution. [See this link for specific commands](https://git-scm.com/download/linux).
* __docker__:
    * __Windows & macOS__: The simplest way to get Docker is to install "Docker Desktop", [which can be done by following this link](https://www.docker.com/products/docker-desktop).
    * __Linux__: You can find installation guide for few Linux distributions [by following this link](https://docs.docker.com/engine/install/ubuntu/).

## Getting the files & Setup your environment
_* You may follow the following steps in both Windows, macOS and Linux. In macOS and Linux, use the standard terminal. In Windows, use PowerShell (unless you're using WSL, in which case - you should treat it as Linux)._

After installing and activating docker, you need to get the files to start working. To do so, you should clone or download this repoistory (`labcc-public`).

You can do so using the command:

```
$ git clone git@github.cs.huji.ac.il:labcc-2020/labcc-public.git
```

Now, you need to setup your computer to begin using the Dockerized valgrind.
__You need to do this step only once__.
`cd` to the `labcc-public` directory, and then:
```
$ cd dockerized-valgrind
$ docker build -t hujilabcc/valgrind:latest .
```

## Usage
To use the program, you need to have a project with `CMakeLists.txt` file (yes, even if you need to submit a `Makefile`, you need an up-to-date `CMakeLists.txt` file to use this project w/o modifications).

### Usage - macOS & Linux
__Basic usage__
Copy `valgrind.sh` to your project directory, and run:
```
$ ./valgrind.sh
```
(If you get "permission denied" error, `valgrind.sh` execution permission by running `chmod 0755 valgrind.sh`).

This execution will run valgrind on the current directory, and show you the output. For example, for the program:

```
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    int* ptr = malloc(sizeof(int));
    printf("Hello, World!\n");
    free(ptr);
    return EXIT_SUCCESS;
}
```

We will get:

```
$ ./valgrind.sh --src=./example

Running valgrind with the following configuration:
- Source Directory:     /Users/yahavbar/Dropbox/CS Degree/Forth Year/Semester A/C & C++ Workshop/labcc-public/dockerized-valgrind/example
- CMake Arguments:      -DCMAKE_BUILD_TYPE=Debug
- Program Arguments:
----------------------------------------------------------------
-- The C compiler identification is GNU 9.3.0
-- The CXX compiler identification is GNU 9.3.0
-- Check for working C compiler: /usr/bin/gcc
-- Check for working C compiler: /usr/bin/gcc - works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /usr/bin/g++
-- Check for working CXX compiler: /usr/bin/g++ - works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Configuring done
-- Generating done
-- Build files have been written to: /home/labcc/build
Scanning dependencies of target a.out
[ 50%] Building C object CMakeFiles/a.out.dir/main.c.o
[100%] Linking C executable a.out
[100%] Built target a.out
==1== Memcheck, a memory error detector
==1== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==1== Using Valgrind-3.15.0 and LibVEX; rerun with -h for copyright info
==1== Command: ./a.out
==1==
Hello, World!
==1==
==1== HEAP SUMMARY:
==1==     in use at exit: 468 bytes in 4 blocks
==1==   total heap usage: 6 allocs, 2 frees, 512 bytes allocated
==1==
==1== LEAK SUMMARY:
==1==    definitely lost: 0 bytes in 0 blocks
==1==    indirectly lost: 0 bytes in 0 blocks
==1==      possibly lost: 0 bytes in 0 blocks
==1==    still reachable: 468 bytes in 4 blocks
==1==         suppressed: 0 bytes in 0 blocks
==1== Rerun with --leak-check=full to see details of leaked memory
==1==
==1== For lists of detected and suppressed errors, rerun with: -s
==1== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```

#### Options
| Option             |  Description |
|--------------------|-----------------------------------------------------------|
| `-s=` or `--src=`  | The (absolute or relative) path to the source directory. |
| `-a=` or `--args=` |  Arguments string to pass __to your program__ (the CLI args that will be forwared to `argv`). |
| `-c=` or `--cmake-args=`  | Extra arguments to send to CMake (for example, `--cmake-args="-DCMAKE_BUILD_TYPE=Debug"`) |
| `--full-leak-check` | If set, valgrind will perform full leak check. |


#### Examples
##### Run with custom source & args
Let's say we have the following program, located at `/cs/yahavb/C/example.c`:

```
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
	if (argc != 3) {
		fprintf(stderr, "Invalid arguments count.");
		return EXIT_FAILURE;
   }
	
   FILE *f = fopen(argv[1], 'w+');
   if (f == NULL) {
   		fprintf(stderr, "Could not find the file.");            
   		return EXIT_FAILURE;
   }

   fprintf(f, "%s", argv[2]);
   fclose(fptr);
   return EXIT_SUCCESS;
}
```

To execute valgrind, you can use:
```
$ valgrind.sh --src=/cs/yahavb/C --args="/cs/yahavb/example.txt hello"
```

##### Custom flags (macro definitions) & Full Leak Check
We can use the CMake args to define macros in the compilation process:
```
$ ./valgrind.sh --cmake-args="-DDEBUG -DNUM=14" --full-leak-check
```
That command will compile the program that is located at the same directory of `valgrind.sh`, with the macros `DEBUG` and `NUM` (with value 14). Moreover, the program will be evaluated within valgrind in full leak check mode.

### Windows
The execution of valgrind in Windows is very similar to macOS and Linux, but we're using a PowerShell script (`ps1`) instead of bash.


__Basic usage__
Copy `valgrind.ps1` to your project directory, and run in PowerShell:
```
$ ./valgrind.ps1
```
This execution will run valgrind on the current directory, and show you the output.

#### Options
| Option             |  Description |
|--------------------|-----------------------------------------------------------|
| `--Source`  | The (absolute or relative) path to the source directory. |
| `--ProgramArgs` |  Arguments string to pass __to your program__ (the CLI args that will be forwared to `argv`). |
| `--CMakeArgs`  | Extra arguments to send to CMake (for example, `--cmake-args="-DCMAKE_BUILD_TYPE=Debug"`) |
| `--FullLeakCheck` | If set, valgrind will perform full leak check. |

### Examples
##### Run with custom source & args
Let's say we have the following program, located at `C:\Users\yahavb\C\example.c`:

```
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
	if (argc != 3) {
		fprintf(stderr, "Invalid arguments count.");
		return EXIT_FAILURE;
   }
	
   FILE *f = fopen(argv[1], 'w+');
   if (f == NULL) {
   		fprintf(stderr, "Could not find the file.");            
   		return EXIT_FAILURE;
   }

   fprintf(f, "%s", argv[2]);
   fclose(fptr);
   return EXIT_SUCCESS;
}
```

To execute valgrind, you can use:
```
$ valgrind.ps1 --Source "C:\Users\yahavb\C\example.c" --ProgramArgs "C:\Users\yahavb\example.txt hello"
```

##### Custom flags (macro definitions) & Full Leak Check
We can use the CMake args to define macros in the compilation process:
```
$ ./valgrind.sh --CMakeArgs "-DDEBUG -DNUM=14" --FullLeakCheck
```
That command will compile the program that is located at the same directory of `valgrind.ps1`, with the macros `DEBUG` and `NUM` (with value 14). Moreover, the program will be evaluated within valgrind in full leak check mode.