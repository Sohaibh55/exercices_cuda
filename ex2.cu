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
            int idx = i * height + j;
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
            int idx = i * height + j;
            printf("%d " , mtx[idx]);
        }
        printf("\n");
    }
}

void set_up(int rows,int cols,int blockDimX,int blockDimY) {

    int n = rows * cols;
    size_t size = rows * cols * sizeof(float);
    float* h_a = (float*)malloc(size);
   
    

    float* d_a ;
    cudaMalloc(&d_a,size);

    


    int gridDimX = blockDimX + cols - 1 / blockDimX;
    int gridDimY = blockDimY + rows - 1 / blockDimY;


    dim3 block(blockDimX,blockDimY);
    dim3 grid(gridDimX,gridDimY);


    remplir<<<grid,block>>>(d_a,rows,cols);
    cudaDeviceSynchronize();

    cudaMemcpy(h_a,d_a,size,cudaMemcpyDeviceToHost);

    PrintOut(h_a,cols,rows);

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
