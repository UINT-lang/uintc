#!/bin/bash

FILE=$1
echo "Running $FILE"
build/uintc $FILE > build/tmp.$FILE.cpp
if [ $? -ne 0 ]; then
    echo "Failed to compile $FILE"
    exit 1
fi
g++ --std=c++20 build/tmp.$FILE.cpp -o build/tmp.$FILE.exe
if [ $? -ne 0 ]; then
    echo "Failed to compile $FILE"
    exit 1
fi
INFILE=$(echo $FILE | sed 's/\.uint/\.in/')
ANSFILE=$(echo $FILE | sed 's/\.uint/\.ans/')
build/tmp.$FILE.exe < $INFILE > build/tmp.$FILE.out
if [ $? -ne 0 ]; then
    echo "Failed to run $FILE"
    exit 1
fi
diff $ANSFILE build/tmp.$FILE.out
if [ $? -ne 0 ]; then
    echo "Failed test $FILE"
    exit 1
fi
echo "Passed $FILE"
