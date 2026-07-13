#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>

__global__ void remplir(float* mtx,int rows,int cols) {

    int row = blockDim.y * blockIdx.y + threadIdx.y;
    int col = blockDim.x * blockIdx.x + threadIdx.x;
    
    if ( row < rows && col < cols) {
        int idx = row * cols + col;
        mtx[idx] = idx;
    }
}
void fillMAtrix(float* mtx,int width,int height) {
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int idx = i * width + j;
            float value = rand() % 5;
            mtx[idx] = value;
        }
    }
}
void PrintOut(float* mtx,int width,int height) {
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int idx = i * width + j;
            printf("%f " , mtx[idx]);
        }
        printf("\n");
    }
}

void set_up(int rows,int cols,int blockDimX,int blockDimY) {

    int n = rows * cols;
    size_t size =  n * sizeof(float);
    float* h_a = (float*)malloc(size);
   
    

    float* d_a ;
    
    cudaError_t err = cudaMalloc(&d_a,size);

    if( err != cudaSuccess) printf("%s\n" , cudaGetErrorString(err));


    int gridDimX = (blockDimX + cols - 1) / blockDimX;
    int gridDimY = (blockDimY + rows - 1) / blockDimY;


    dim3 block(blockDimX,blockDimY);
    dim3 grid(gridDimX,gridDimY);


    remplir<<<grid,block>>>(d_a,rows,cols);
    cudaDeviceSynchronize();

    cudaMemcpy(h_a,d_a,size,cudaMemcpyDeviceToHost);

    PrintOut(h_a,cols,rows);

    int thread_in = gridDimX * gridDimY * blockDimX * blockDimY;
    int thread_out = thread_in - n;

    printf("Grid dimension : %d , %d\n" , gridDimX , gridDimY);
    printf("Thread ToTal : %d\n" , thread_in);
    printf("out of bound Thread ToTal : %d\n" , thread_out);

    cudaFree(d_a);free(h_a);
    
}
int main(int argc , char* argv[]) {

    if (argc != 5) {
        printf("Error: %s requires 4 arguments", argv[0]);
        exit(1);
    }


    int rows = atoi(argv[1]), cols = atoi(argv[2]), blockDimX = atoi(argv[3])
    , blockDimY = atoi(argv[4]);


    set_up(rows,cols,blockDimX,blockDimY);



}