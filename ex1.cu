#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>

__global__ void Naif_gpu(const float* M,const float*N,float*P,const int m,const int K,const int n){

        int row = blockIdx.y * blockDim.y +threadIdx.y;
        int col = blockIdx.x * blockDim.x + threadIdx.x;

        if( row < m && col < n) {
            float sum=0.0f;
            for (int i = 0; i < K; i++) {
                int idx = row * K + i;
                int idy = i * n + col;

                sum += M[idx] * N[idy];
            }
            P[ row * n + col ] = sum; 
        }

}
void Naif_cpu(const float* M, const float* N,
              float* P, const int m, const int K, const int n) 
{ 
    float sum ;
    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < n; j++)
        {
            sum = 0.0f;
            for (int k = 0; k < K; k++)
            {
                int idx = i * K + k;
                int idy =  j + k * n;
                
                sum += M[idx] * N[idy];
            }
            P[i * n + j] = sum;
        }
    }
}
void fillMatrix(float* mtx,int width,int height) {
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int idx = i * width + j;
            mtx[idx] = rand() / (float)RAND_MAX;
        }
    }
}
void PrintOut(const float* mtx,int height,int width) {
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
bool check_diff(const float* mtx_cpu,const float* mtx_gpu,const int height,const int width) {
   
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int idx = i * width + j;
            if(mtx_cpu[idx] != mtx_gpu[idx]) return false;
        }
    }
    return true;
}
void err_max(const float* mtx_cpu,const float* mtx_gpu,const int width,const int height) {
    
    float cur_err , err = 0.0f;
    

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int idx = i * width + j;
            cur_err = abs( mtx_gpu[idx] - mtx_cpu[i]);

            if ( cur_err > err ) err = cur_err ; 
        }
    }
}
void set_up(int m,int k,int n) {

    size_t sizeM =   m * k * sizeof(float);
    size_t sizeN =   k * n * sizeof(float);
    size_t sizeP =   m * n * sizeof(float);
   
    float* M , *N , *P_gpu,*P_cpu , *P_d_h;
    
    cudaMallocHost(&M,sizeM);
    cudaMallocHost(&N,sizeN);
    
    P_cpu = (float*)malloc(sizeP);
    P_d_h = (float*)malloc(sizeP);

    cudaMalloc(&P_gpu,sizeP);

    
    fillMatrix(M,m,k);
    fillMatrix(N,k,n);


    int blockDimX = 16;
    int blockDimY = 16;
    int gridDimX = (m + blockDimX  - 1) / blockDimX;
    int gridDimY = (n + blockDimY - 1) / blockDimY;


    dim3 block(blockDimX,blockDimY);
    dim3 grid(gridDimX,gridDimY);


    Naif_cpu(M,N,P_cpu,m,k,n);


    cudaEvent_t start,stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);
    
    Naif_gpu<<<grid,block>>>(M,N,P_gpu,m,k,n);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    float time;
    cudaEventElapsedTime(&time,start,stop);
    
    
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    cudaMemcpy(P_d_h,P_gpu,sizeP,cudaMemcpyDeviceToHost);

    // PrintOut(h_a,height,width);
    // PrintOut(d_h_a,height,width);

    int thread_in = gridDimX * gridDimY * blockDimX * blockDimY;
    int thread_out = thread_in - n;

    printf("Grid dimension : %d , %d\n" , gridDimX , gridDimY);
    printf("Thread ToTal : %d\n" , thread_in);
    printf("out of bound Thread ToTal : %d\n" , thread_out);
    printf("Kernel time = %f ms\n" , time);

    if(check_diff(P_d_h,P_cpu,m,n) ) printf("The results are the same");
    else printf("The results are differents");

    cudaFree(P_gpu);
    free(M);free(N);
    free(P_cpu);free(P_d_h);

}
int main(int argc , char* argv[]) {
   
    srand(42);
    
    const int TestSize = 1;

    int m[TestSize] = {512};
    int k[TestSize] = {512};
    int n[TestSize] = {512};
    
    for (int i = 0; i < TestSize; i++)
        set_up(m[i],k[i],n[i]);
    
}