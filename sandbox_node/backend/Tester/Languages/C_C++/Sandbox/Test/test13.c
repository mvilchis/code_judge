#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv)
{
	int N = 1000000;
	double* a = (double*)malloc(N*sizeof(double));
	memset(a,0,N*sizeof(double));
	printf("%lf\n", a[999999]);
   return 0;
}
