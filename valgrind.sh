#!/bin/bash

#----------------------------------------------------------------
# Helper functions
#----------------------------------------------------------------

function print_header() {
    echo " ______   _______  _______  _        _______  _______ _________ _______  _______  ______  "
    echo "(  __  \ (  ___  )(  ____ \| \    /\(  ____ \(  ____ )\__   __// ___   )(  ____ \(  __  \ "
    echo "| (  \  )| (   ) || (    \/|  \  / /| (    \/| (    )|   ) (   \/   )  || (    \/| (  \  )"
    echo "| |   ) || |   | || |      |  (_/ / | (__    | (____)|   | |       /   )| (__    | |   ) |"
    echo "| |   | || |   | || |      |   _ (  |  __)   |     __)   | |      /   / |  __)   | |   | |"
    echo "| |   ) || |   | || |      |  ( \ \ | (      | (\ (      | |     /   /  | (      | |   ) |"
    echo "| (__/  )| (___) || (____/\|  /  \ \| (____/\| ) \ \_____) (___ /   (_/\| (____/\| (__/  )"
    echo "(______/ (_______)(_______/|_/    \/(_______/|/   \__/\_______/(_______/(_______/(______/ "
    echo "                                                                                          "
    echo "          _______  _        _______  _______ _________ _        ______  "
    echo "|\     /|(  ___  )( \      (  ____ \(  ____ )\__   __/( (    /|(  __  \ "
    echo "| )   ( || (   ) || (      | (    \/| (    )|   ) (   |  \  ( || (  \  )"
    echo "| |   | || (___) || |      | |      | (____)|   | |   |   \ | || |   ) |"
    echo "( (   ) )|  ___  || |      | | ____ |     __)   | |   | (\ \) || |   | |"
    echo " \ \_/ / | (   ) || |      | | \_  )| (\ (      | |   | | \   || |   ) |"
    echo "  \   /  | )   ( || (____/\| (___) || ) \ \_____) (___| )  \  || (__/  )"
    echo "   \_/   |/     \|(_______/(_______)|/   \__/\_______/|/    )_)(______/ "
    echo "                                                                        "
}


function print_help() {
    print_header
    cat << EOF

Usage: ./valgrind.sh [--src=<directory>][--cmake-args=<args>][--full-leak-check]
Options:
    -s, --src           The source directory to compile and
                        run valgrind against.
    -a, --args          Arguments to pass to the program.
    -c, --cmake-args    A string of arguments to send to CMake.
    --full-leak-check   If set, valgrind will run with full
                        leak check flags.

Examples:
    *) ./valgrind.sh --args="arg1 arg2"
    *) ./valgrind.sh --full-leak-check --src=./example
    *) ./valgrind.sh --src="/Users/yahavbar/CLionProjects/c-ex1" --args="5 /path/to/input.txt" --full-leak-check
    *) ./valgrind.sh --cmake-args="-DCMAKE_BUILD_TYPE=Release"
EOF
    exit 1
}

resolve_path() {
  OURPWD=$PWD
  cd "$(dirname "$1")"
  LINK=$(readlink "$(basename "$1")")
  while [ "$LINK" ]; do
    cd "$(dirname "$LINK")"
    LINK=$(readlink "$(basename "$1")")
  done
  REALPATH="$PWD/$(basename "$1")"
  cd "$OURPWD"
  echo "$REALPATH"
}

#----------------------------------------------------------------
# Parse arguments
#----------------------------------------------------------------
PROGRAM_ARGS=""
SOURCE_DIRECTORY=$(pwd)
CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Debug"
FULL_LEAK_CHECK=0

for i in "$@"
    do
    case $i in
        --help)
        print_help
        shift
        ;;
        -s=*|--src=*)
        SOURCE_DIRECTORY="${i#*=}"
        SOURCE_DIRECTORY=$(resolve_path "$SOURCE_DIRECTORY")
        shift
        ;;
        -a=*|--args=*)
        PROGRAM_ARGS="${i#*=}"
        shift
        ;;
        -c=*|--cmake-args=*)
        CMAKE_ARGS="${i#*=}"
        shift # past argument=value
        ;;
        -l=*|--lib=*)
        LIBPATH="${i#*=}"
        shift # past argument=value
        ;;
        --full-leak-check)
        FULL_LEAK_CHECK=1
        shift
        ;;
        *)
        # unknown option
        ;;
    esac
done

print_header
cat << EOF 
Running valgrind with the following configuration:
- Source Directory:     $SOURCE_DIRECTORY
- CMake Arguments:      $CMAKE_ARGS
- Program Arguments:    $PROGRAM_ARGS
----------------------------------------------------------------
EOF


#----------------------------------------------------------------
# Check that we have a CMakeLists.txt in the source directory.
#----------------------------------------------------------------
if [ ! -f "$SOURCE_DIRECTORY/CMakeLists.txt" ]; then
    echo "A CMakeLists.txt could not be found at the source directory: $SOURCE_DIRECTORY"
    echo "Please create a CMakeLists.txt file or point the source directory, using --src, to the correct location."
    exit 1
fi

#----------------------------------------------------------------
# Setup valgrind flags
#----------------------------------------------------------------
if [ $FULL_LEAK_CHECK -eq 1 ]; then
    VALGRIND_ARGS="--leak-check=full --leak-resolution=med --track-origins=yes"
else
    VALGRIND_ARGS=""
fi

# Other non-configurable constants
DOCKER_IMAGE_NAME='hujilabcc/valgrind'
EXECUTABLE_NAME='a.out'

# Run
exec docker run --rm -i \
    -v "$SOURCE_DIRECTORY":/input:ro \
    $DOCKER_IMAGE_NAME /bin/sh -c \
    "cmake $CMAKE_ARGS /input/ && make && valgrind $VALGRIND_ARGS ./$EXECUTABLE_NAME $PROGRAM_ARGS"

exit $?