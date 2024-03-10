#!/bin/bash

num_tc=$1
low_n=$2
high_n=$3

g++ test/gen.cpp -o test/gen
g++ test/sol.cpp -o test/sol
nvcc ../code/CS20B084.cu -o CS20B084

num_passed=0

for i in $(seq 1 $num_tc)
do
    test/gen $low_n $high_n > test/in.txt
    test/sol < test/in.txt > test/correct.txt
    ./CS20B084 < test/in.txt

    if [[ $(diff test/correct.txt cuda.out) == "" ]]
    then
        num_passed=$((num_passed+1))
    fi
done

echo "passed " $num_passed "/" $num_tc
rm cuda.out cuda_timing.out test/in.txt test/correct.txt