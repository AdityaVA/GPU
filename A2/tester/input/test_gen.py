'''
Test Generator for GPU A1

This script generates a test file for the GPU A1 assignment. 

Usage:

    python TestGenerator.py -f test.txt -n 1024
    where -f denotes the path of the file to generate and -n denotes the number N.
    Default values are test.txt and 1024 respectively.
'''

import random
import argparse

parser = argparse.ArgumentParser(description="Generate a test file.")

# Add the arguments
parser.add_argument('-f', '--file', type=str, default='test.txt', help='The name of the file to generate.')
parser.add_argument('-n', '--cols', type=int, default=1024, help='The number N.')
parser.add_argument('-m', '--rows', type=int, default=1024, help='The number M.')
parser.add_argument('-k', '--filter', type=int, default=50, help='The number K.')

# Parse the arguments
args = parser.parse_args()

filename = args.file
N = args.cols
M = args.rows
K = args.filter

file = open(filename, "w")

####

print(M, N, K)

file.write(str(M) + " " + str(N) + " " + str(K) + "\n")

for _ in range(M):
    for _ in range(N):
        file.write(str(random.randint(0, 100)) + " ")
    file.write("\n")
print("Matrix done")

for _ in range(K):
    for _ in range(K):
        file.write(str(random.randint(0, 100)) + " ")
    file.write("\n")
print("Filter done")

