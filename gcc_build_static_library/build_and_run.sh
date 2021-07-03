#!/bin/bash
gcc -c main.c -o main.o

gcc -c add.c -o add.o

gcc -c subtraction.c -o subtraction.o

ar rcs libmath.a add.o subtraction.o

gcc main.o -L./ -lmath -o math_statically_linked

./math_statically_linked
