#!/bin/bash

mkdir -p build/tmp.tests/luogu

for FILE in $(find tests -name "*.uint")
do
    tests/runone.sh $FILE &
done

wait
