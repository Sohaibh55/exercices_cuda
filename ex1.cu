#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>

__global__ void kernel_1D() {

    int row = blockDim.y * blockIdx.y + threadIdx.y;
    int col = blockDim.x * blockIdx.x + threadIdx.x;
    int idx = row * (gridDim.x * blockDim.x) + col;

    printf("Block(%d,%d) Thread(%d,%d) -> Global: %d\n" , blockIdx.x,blockIdx.y , threadIdx.x,threadIdx.y
                                                        ,idx);
}


int main(int argc , char* argv[]) {
    if (argc != 5) {
        printf("Error: %s requires 4 arguments", argv[0]);
        exit(1);
    }

    int gridDimX = atoi(argv[1]), gridDimY = atoi(argv[2]), blockDimX = atoi(argv[3])
    , blockDimY = atoi(argv[4]);


    dim3 grid(gridDimX,gridDimY);
    dim3 block(blockDimX,blockDimY);
    
    kernel_1D<<<grid,block>>>();

    cudaDeviceSynchronize();



}
