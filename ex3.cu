#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>

__global__ void mult_gpu(float* mtx,int rows,int cols) {

    int row = blockDim.y * blockIdx.y + threadIdx.y;
    int col = blockDim.x * blockIdx.x + threadIdx.x;
    
    if ( row < rows && col < cols) {
        int idx = row * cols + col;
        mtx[idx] = mtx[idx] * 2.0f;
    }
}
void multi_cpu(float* mtx,int rows,int cols) {
    
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            int idx = i * cols + j;
            mtx[idx] = mtx[idx] * 2.0f;
        }
        
    }
    
}
void fillMatrix(float* mtx,int width,int height) {
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int idx = i * width + j;
            float value = 1.0f;
            mtx[idx] = value;
        }
    }
    printf("\n")
}
void PrintOut(float* mtx,int width,int height) {
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int idx = i * width + j;
            printf("%.2f " , mtx[idx]);
        }
        printf("\n");
    }
}
bool check_diff(float* mtx_cpu,float* mtx_gpu,int rows,int cols) {
   
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            int idx = i * cols + j;
            if(mtx_cpu[idx] != mtx_gpu[idx]) return false;
        }
    }
    return true
    
}
void set_up(int rows,int cols,int blockDimX,int blockDimY) {

    int n = rows * cols;
    size_t size =  n * sizeof(float);
    float* h_a = (float*)malloc(size);
    float* d_h_a = (float*)malloc(size);
   
    fillMatrix(h_a,rows,cols);

    float* d_a ;
    
    cudaError_t err = cudaMalloc(&d_a,size);

    if( err != cudaSuccess) printf("%s\n" , cudaGetErrorString(err));

    cudaMemcpy(d_a,h_a,size,cudaMemcpyHostToDevice);

    int gridDimX = (blockDimX + cols - 1) / blockDimX;
    int gridDimY = (blockDimY + rows - 1) / blockDimY;


    dim3 block(blockDimX,blockDimY);
    dim3 grid(gridDimX,gridDimY);


    multi_cpu(h_a,rows,cols);


    cudaEvent_t start,stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);
    
    mult_gpu<<<grid,block>>>(d_a,rows,cols);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    float time;
    cudaEventElapsedTime(&time,start,stop);
    
    
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    cudaMemcpy(d_h_a,d_a,size,cudaMemcpyDeviceToHost);

    PrintOut(h_a,cols,rows);
    PrintOut(d_h_a,cols,rows);

    int thread_in = gridDimX * gridDimY * blockDimX * blockDimY;
    int thread_out = thread_in - n;

    printf("Grid dimension : %d , %d\n" , gridDimX , gridDimY);
    printf("Thread ToTal : %d\n" , thread_in);
    printf("out of bound Thread ToTal : %d\n" , thread_out);
    printf("Kernel time = %f ms\n" , time);

    if(check_diff(d_h_a,h_a,rows,cols) ) printf("The results are the same");
    else printf("The results are differents");

    cudaFree(d_a);free(h_a);

}
int main(int argc , char* argv[]) {

    int rows =  5000, cols = 5000 ;

    int sizes[6] = {32,64,128,256,512,1024};

    for (int i = 0; i < 6; i++) {

        printf("For [ %d,%d ] :\n" , sizes[i] , sizes[i]);
        set_up(rows,cols,sizes[i],sizes[i]);
    }

}