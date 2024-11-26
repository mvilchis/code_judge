#include <stdio.h>
#include <stdlib.h>

int main(){
	int n = 2097000;
	int* x = new int[n];
	x[0]=0;
	for(int i=1; i<n;i++){
		x[i] = x[i-1]+1;
	}
	printf("%d",x[n-100]);
	return 0;
}
