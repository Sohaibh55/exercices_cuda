#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>

__global__ void kernel_1D() {
    int row = blockDim.y * blockIdx.y + threadIdx.y;
    int col = blockDim.x * blockIdx.x + threadIdx.x;
    int id = row * (gridDim.x * blockDim.x) + col; 

    printf( "Block (%d,%d) Thread(%d,%d) -> Global %d" , 
    blockIdx.x , blockIdx.y , threadIdx.x , threadIdx.y , id);
}

int main(int argc , char* argv[]) {
if (argc != 4) {
    printf("Error: %s requires 4 arguments", argv[0]);
    exit(1);
}

int gridDimX = atoi(argv[1]), gridDimY = atoi(argv[2]), blockDimX = atoi(argv[3])
, blockDimY = atoi(argv[4]);


}
