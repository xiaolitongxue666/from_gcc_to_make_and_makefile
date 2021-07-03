#!/bin/bash
gcc -c main.c -o main.o

gcc -c -fPIC add.c -o add.o

gcc -c -fPIC subtraction.c -o subtraction.o

gcc -shared add.o subtraction.o -o libmath.so

gcc main.o -L./ -lmath -o math_dynamic_linked

export LD_LIBRARY_PATH=$(pwd)

./math_dynamic_linked


