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
void fillMatrix(float* mtx,int height,int width) {
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

void output( const int m, const int k, const int n , const float err) {
    printf("=== Noyau naif === \n");
    printf("M(%dx%d) * N(%dx%d) = P(%dx%d) Err max: %f\n" , m , k , k , n , m , n , err);
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
float err_max(const float* mtx_cpu,const float* mtx_gpu,const int height,const int width) {
    
    float cur_err , err = 0.0f;
    

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int idx = i * width + j;
            cur_err = fabs( mtx_gpu[idx] - mtx_cpu[idx]);

            if ( cur_err > err ) err = cur_err ; 
        }
    }
    return err;
}
void set_up(int m,int k,int n) {

    size_t sizeM =   m * k * sizeof(float);
    size_t sizeN =   k * n * sizeof(float);
    size_t sizeP =   m * n * sizeof(float);
   
    float* M , *N ,*M_gpu , *N_gpu , *P_gpu,*P_cpu , *P_d_h;
    
    cudaMalloc(&M_gpu, sizeM);
    cudaMalloc(&N_gpu, sizeN);

    cudaMallocHost(&M,sizeM);
    cudaMallocHost(&N,sizeN);
    
    P_cpu = (float*)malloc(sizeP);
    P_d_h = (float*)malloc(sizeP);

    cudaMalloc(&P_gpu,sizeP);

    
    fillMatrix(M,m,k);
    fillMatrix(N,k,n);

    cudaMemcpy(M_gpu,M,sizeM,cudaMemcpyHostToDevice);
    cudaMemcpy(N_gpu,N,sizeN,cudaMemcpyHostToDevice);

    int blockDimX = 16;
    int blockDimY = 16;
    int gridDimX = (n + blockDimX  - 1) / blockDimX;
    int gridDimY = (m + blockDimY - 1) / blockDimY;


    dim3 block(blockDimX,blockDimY);
    dim3 grid(gridDimX,gridDimY);


    Naif_cpu(M,N,P_cpu,m,k,n);


    cudaEvent_t start,stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);
    
    Naif_gpu<<<grid,block>>>(M_gpu,N_gpu,P_gpu,m,k,n);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    float time;
    cudaEventElapsedTime(&time,start,stop);
    
    
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    cudaMemcpy(P_d_h,P_gpu,sizeP,cudaMemcpyDeviceToHost);

    float err = err_max(P_cpu,P_d_h,m,n);

    output(m,k,n,err);

    cudaFree(P_gpu);cudaFree(M_gpu);cudaFree(N_gpu);
    
    cudaFreeHost(M);cudaFreeHost(N);

    free(P_cpu);free(P_d_h);
    

}
int main(int argc , char* argv[]) {
   
    srand(42);
    
    set_up(512,512,512);
    set_up(1024,1024,1024);
    set_up(2048,2048,2048);

    set_up(2048,1024,512);
    set_up(1024,4096,512);
    set_up(1000,1500,2000);
    
}