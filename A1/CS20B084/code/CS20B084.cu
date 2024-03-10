/**
*   CS6023: GPU Programming 
*   Assignment 1
*   
*   Please don't change any existing code in this file.
*
*   You can add your code whereever needed. Please add necessary memory APIs
*   for your implementation. Use cudaFree() to free up memory as soon as you're
*   done with an allocation. This will ensure that you don't run out of memory 
*   while running large test cases. Use the minimum required memory for your 
*   implementation. DO NOT change the kernel configuration parameters.
*/

#include <chrono>
#include <fstream>
#include <iostream>
#include <cuda.h>

using std::cin;
using std::cout;


__global__
void CalculateHadamardProduct(long int* A, long int* B, int N) {

    // TODO: Write your kernel here
    //A[N*i+j] = A[N*i+j]*B[N*j+i]
    int id = (blockIdx.y * gridDim.x + blockIdx.x)*blockDim.x*blockDim.y 
    + threadIdx.y*blockDim.x + threadIdx.x;
    int i = id/N;
    int j = id%N;
    if(id<N*N)
    {
        A[N*i+j] = A[N*i+j]*B[N*j+i];
    }
}

__global__
void FindWeightMatrix(long int* A, long int* B, int N) {

    // TODO: Write your kernel here
    int id = (blockIdx.y * gridDim.x + blockIdx.x)*blockDim.x*blockDim.y 
    + threadIdx.y*blockDim.x + threadIdx.x;
    if(id<N*N)
    {
        A[id] = max(A[id],B[id]);
    }
}

__global__
void CalculateFinalMatrix(long int* A, long int* B, int N) {

    // TODO: Write your kernel here
    int id = (blockIdx.y * gridDim.x + blockIdx.x)*blockDim.x*blockDim.y 
    + threadIdx.y*blockDim.x + threadIdx.x;
    
    if(id < 2 * N * 2 * N)
    {
        int i = id/(2*N);
        int j = id%(2*N);
        int weight_i = i%N;
        int weight_j = j%N;
        // printf("%d %d %d %d %d %d\n",id,i,j,weight_i,weight_j,N);
        B[2*N*i+j] = A[N*weight_i+weight_j]*B[2*N*i+j];
    }
}


int main(int argc, char** argv) {


    int N;
    cin >> N;
    long int* A = new long int[N * N];
    long int* B = new long int[N * N];
    long int* C = new long int[N * N];
    long int* D = new long int[2 * N * 2 * N];


    for (long int i = 0; i < N * N; i++) {
        cin >> A[i];
    }

    for (long int i = 0; i < N * N; i++) {
        cin >> B[i];
    }

    for (long int i = 0; i < N * N; i++) {
        cin >> C[i];
    }

    for (long int i = 0; i < 2 * N * 2 * N; i++) {
        cin >> D[i];
    }

    /**
     * 
     * DO NOT CHANGE ANYTHING ABOVE THIS LINE
     * 
    */

    long int* d_A;
    long int* d_B;
    long int* d_C;
    long int* d_D;

    dim3 threadsPerBlock(1024, 1, 1);
    dim3 blocksPerGrid(ceil(N * N / 1024.0), 1, 1);
    //first copy A, B matrices to device memory
    cudaMalloc(&d_A, N * N * sizeof(long int));
    cudaMemcpy(d_A, A, N * N * sizeof(long int), cudaMemcpyHostToDevice);
    cudaMalloc(&d_B, N * N * sizeof(long int));
    cudaMemcpy(d_B, B, N * N * sizeof(long int), cudaMemcpyHostToDevice);
    auto start = std::chrono::high_resolution_clock::now();
    CalculateHadamardProduct<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, N);
    cudaFree(d_B);
    cudaDeviceSynchronize();
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed1 = end - start;


    threadsPerBlock = dim3(32, 32, 1);
    blocksPerGrid = dim3(ceil(N * N / 1024.0), 1, 1);
    //Now copy C as well to perform some operations
    cudaMalloc(&d_C, N * N * sizeof(long int));
    cudaMemcpy(d_C, C, N * N * sizeof(long int), cudaMemcpyHostToDevice);

    start = std::chrono::high_resolution_clock::now();
    FindWeightMatrix<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_C, N);
    cudaFree(d_C);
    cudaDeviceSynchronize();
    end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed2 = end - start;


    threadsPerBlock = dim3(32, 32, 1);
    blocksPerGrid = dim3(ceil(2 * N / 32.0), ceil(2 * N / 32.0), 1);

    cudaMalloc(&d_D, 4 * N * N * sizeof(long int));
    cudaMemcpy(d_D, D, 4 * N * N * sizeof(long int), cudaMemcpyHostToDevice);
    start = std::chrono::high_resolution_clock::now();
    CalculateFinalMatrix<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_D, N);
    cudaDeviceSynchronize();
    end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed3 = end - start;
    cudaFree(d_A);
    
    
    // Make sure your final output from the device is stored in d_D.

    /**
     * 
     * DO NOT CHANGE ANYTHING BELOW THIS LINE
     * 
    */

    cudaMemcpy(D, d_D, 2 * N * 2 * N * sizeof(long int), cudaMemcpyDeviceToHost);

    std::ofstream file("cuda.out");
    if (file.is_open()) {
        for (long int i = 0; i < 2 * N; i++) {
            for (long int j = 0; j < 2 * N; j++) {
                file << D[i * 2 * N + j] << " ";
            }
            file << "\n";
        }
        file.close();
    } else {
        std::cout << "Unable to open file";
    }

    std::ofstream file2("cuda_timing.out");
    if(file2.is_open()) {
        file2 << elapsed1.count() << "\n";
        file2 << elapsed2.count() << "\n";
        file2 << elapsed3.count() << "\n";
        file2.close();
    } else {
        std::cout << "Unable to open file";
    }

    return 0;
}