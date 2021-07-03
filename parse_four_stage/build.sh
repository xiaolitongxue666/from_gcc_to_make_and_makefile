#!/bin/bash

gcc -E hello_world.c -o hello_world.i

gcc -S hello_world.i -o hello_world.s

gcc -c hello_world.s -o hello_world.o

gcc hello_world.o -o hello_world
