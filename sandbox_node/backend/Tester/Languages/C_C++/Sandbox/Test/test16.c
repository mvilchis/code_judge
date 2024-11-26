#include <stdio.h>
 
int main ( int argc, char **argv ){
 	FILE *fp = fopen ("fichero.txt", "r+" );
 	fprintf(fp, "%s", "\nEsto es otro texto dentro del fichero.");
 	fclose ( fp );
 	return 0;
}
