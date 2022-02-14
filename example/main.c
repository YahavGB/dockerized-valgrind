#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    int* ptr = malloc(sizeof(int));
    printf("Hello, World!\n");
    // free(ptr); <<< w/o this line, we have a leak.
    return EXIT_SUCCESS;
}