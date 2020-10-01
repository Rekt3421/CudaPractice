#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <iostream>
__global__ void mykernel(int *a, int *b, int *c, int n)
{
  int index = blockIdx.x*blockDim.x + threadIdx.x;

  if (index < n)
  {
    c[index] = a[index] + b[index];

  }
}
int* genVector(int *p, int n)
{
  std::cout << " Vector : " ;
  for (int i = 0; i < n; i++)
  {
    p[i] = rand()/100;
    std::cout << p[i] << " ";
  }
  std::cout << "" << std::endl;
  return p;
}

#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort = true)
{
  if (code != cudaSuccess)
  {
    fprintf(stderr, "GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
    if (abort) exit(code);
  }
}
int main(void)
{
  int *h_a, *h_b, *h_c;
  int *d_a, *d_b, *d_c;
  
  int n = 16;
  int NUM_THREADS = 16;
  int NUM_BLOCKS = (int)ceil(n + NUM_THREADS+1)/NUM_THREADS;
 
  std::size_t bytes = sizeof(int)*n;

  h_a = (int*)malloc(bytes);
  h_b = (int*)malloc(bytes);
  h_c = (int*)malloc(bytes);
 
  gpuErrchk(cudaMalloc(&d_a, bytes));
  gpuErrchk(cudaMalloc(&d_b, bytes));
  gpuErrchk(cudaMalloc(&d_c, bytes));
  
  genVector(h_a, n);
  genVector(h_b, n);

  gpuErrchk(cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice));
  gpuErrchk(cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice));
  cudaMemcpy(d_c, h_c, bytes, cudaMemcpyHostToDevice);

 

  mykernel <<<NUM_BLOCKS, NUM_THREADS >>>(d_a, d_b, d_c, n);
 
  gpuErrchk(cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost));
 

  std::cout << "result : ";
  for (int i = 0; i < n; i++)
    std::cout << (h_c[i]) << " ";
  
  cudaFree(d_a);
  cudaFree(d_b);
  cudaFree(d_c);
  
  free(h_a);
  free(h_b);
  free(h_c);
}