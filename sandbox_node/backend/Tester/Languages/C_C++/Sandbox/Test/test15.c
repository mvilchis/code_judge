#include <stdio.h>

int main(int argc, char **argv)
{
	fprintf(stderr, "Goodbye ");
	fputs("World!\n", stderr);
	return 0;
}
