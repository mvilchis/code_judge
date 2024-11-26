#include <stdio.h>

int main(int argc, char **argv){
	int N = 1000000;
	double* a = new double[N];
	printf("%lf\n", a[999999]);
	delete[] a;
   return 0;
}
