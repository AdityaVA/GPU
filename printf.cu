#include <stdio.h>
#include <cuda.h>
__global__ void dkernel() {
    printf("Hello World.\n");
}
int main() {
    dkernel<<<1, 1>>>();
    printf("CPU one\n");
    dkernel<<<1, 1>>>();
    printf("CPU two\n");
    dkernel<<<1, 1>>>();
    printf("CPU three\n");
	cudaDeviceSynchronize();
    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess)
    {
        // print the CUDA error message and exit
        printf("CUDA error: %s\n", cudaGetErrorString(error));
        exit(-1);
    }
    printf("ON CPU\n");
    return 0;
}