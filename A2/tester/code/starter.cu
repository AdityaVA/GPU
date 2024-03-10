/**
*   CS6023: GPU Programming 
*   Assignment 2
*   
*   Please don't change any existing code in this file.
*
*   Please add necessary memory APIs for your implementation. Use cudaFree() 
*   to free up memory as soon as you're done with an allocation. 
*   This will ensure that you don't run out of memory while running
*   large test cases. Use the minimum required memory for your 
*   implementation. DO NOT change the kernel configuration parameters.
*/

#include <chrono>
#include <fstream>
#include <iostream>
#include <stdio.h>
#include <cuda.h>

using namespace std;

using std::cin;
using std::cout;

typedef long long ll;

__global__
void convolve(long int* d_mat, long int* d_ans, long int* d_filter, int m, int n, int k) {

    
    int id = (blockIdx.y * gridDim.x + blockIdx.x)*blockDim.x*blockDim.y 
    + threadIdx.y*blockDim.x + threadIdx.x;
    extern __shared__ long int filter[];
    if(threadIdx.x == 0)
    {
        for(int i = 0; i < k; i++)
        {
            for(int j = 0; j < k; j++)
            {
                filter[i*k+j] = d_filter[i*k + j];
            }
        }
        // printf("Input : %d %d %d\n", m, n, k);
    }

    __syncthreads();

    int i = id / n;
    int j = id % n;

    if(i < m && j < n)
    {
        long int sum = 0;
        for(int x = 0; x < k; x++)
        {
            for(int y = 0; y < k; y++)
            {
                int cur_i = i - k/2 + x;
                int cur_j = j - k/2 + y;
                if(cur_i >= 0 && cur_i < m && cur_j >= 0 && cur_j < n)
                {
                    sum += d_mat[cur_i * n + cur_j] * filter[x * k + y];
                }
            }
        }
        d_ans[i * n + j] = sum;
    }

}

int main(int argc, char** argv) {

    int m,n,k;
    cin>>m>>n>>k;


    long int* h_mat = new long int[m * n];
    long int* h_filter = new long int[k * k];

    long int* h_ans = new long int[m * n];


    for (long int i = 0; i < m * n; i++) {
        cin>>h_mat[i];
    }

    for (long int i = 0; i < k * k; i++) {
        cin>>h_filter[i];
    }

    /**
     * 
     * DO NOT CHANGE ANYTHING ABOVE THIS LINE
     * 
    **/

    /****************************************************Start Here***********************************************************/
    // dim3 threadsPerBlock = dim3(32, 32, 1);
    // dim3 blocksPerGrid = dim3(ceil(n * m / 1024.0), 1, 1);
    dim3 threadsPerBlock = dim3(n, 1, 1);
    dim3 blocksPerGrid = dim3(m, 1, 1);
    long int* d_mat;
    long int* d_filter;
    long int* d_ans;

    cudaMalloc(&d_mat, m * n * sizeof(long int));
    cudaMalloc(&d_filter, k * k * sizeof(long int));
    cudaMalloc(&d_ans, m * n * sizeof(long int));

    cudaMemcpy(d_mat, h_mat, m * n * sizeof(long int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_filter, h_filter, k * k * sizeof(long int), cudaMemcpyHostToDevice);

    auto start = std::chrono::high_resolution_clock::now();//keep it just before the kernel launch

    convolve<<<blocksPerGrid, threadsPerBlock, k * k * sizeof(long int)>>>(d_mat, d_ans, d_filter, m, n, k);
    cudaDeviceSynchronize();
    auto end = std::chrono::high_resolution_clock::now();//keep it just after the kernel launch
    
    cudaMemcpy(h_ans, d_ans, m * n * sizeof(long int), cudaMemcpyDeviceToHost);
    
    /*$$$$$$$$$$$$$$$$$$$$$$$$Make sure your final output from the device is stored in h_ans.$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*/
    std::chrono::duration<double> elapsed1 = end - start;
    /**
     * 
     * DO NOT CHANGE ANYTHING BELOW THIS LINE
     * 
    */


    
    std::ofstream file("cuda.out");
    if (file.is_open()) {
        for (long int i = 0; i < m; i++) {
            for (long int j = 0; j < n; j++) {
                file << h_ans[i * n + j] << " ";
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
        file2.close();
    } else {
        std::cout << "Unable to open file";
    }

    return 0;
}