#include <stdio.h>
#include <stdlib.h>


void Naif_cpu(float* M,float*N,float*P,int rowsM,int colsM , int colsN) {
    
    for (int i = 0; i < rowsM; i++)
    {
        for (int j = 0; j < colsN; j++)
        {
            float sum=0.0f;
            
            for (int k = 0; k < colsM; k++)
            {

                int idx = i * colsM + k;
                int idy = k * colsN + j;

                sum += M[idx] * N[idy];
            }
            P[i * colsN + j] = sum;
        }   
    }
}
void fillMatrix(float* mtx,int width,int height) {
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int idx = i * width + j;
            mtx[idx] = rand() % 5;
        }
    }
}
void PrintOut(float* mtx,int width,int height) {
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int idx = i * width + j;
            printf("%.0f " , mtx[idx]);
        }
        printf("\n");
    }
}

int main() {

    float M[25] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,1,2,3,4,5};

    float N[25] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,1,2,3,4,5};
    float P[25];
    // fillMatrix(M,5,5);
    // fillMatrix(N,5,5);

    Naif_cpu(M,N,P,5,5);

    PrintOut(M,5,5);
    printf("\n\n");
    PrintOut(M,5,5);
    printf("\n\n");
    PrintOut(P,5,5);

}