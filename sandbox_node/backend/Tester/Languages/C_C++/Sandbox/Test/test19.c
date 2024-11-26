#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int main( int argc, char *argv[] ){
	char command[50];
   strcpy(command, "ls -l" );
   system(command);
   return 0;
}

