/* Test that printf works
 * You'd be amazed how many systems calls are used in modern
 * libcs just to print text to stdout. */

#include <stdio.h>

int main(void) {
	int x = 5;
	float y = 6.1;
	char s[] ="entro";
	printf("Hello, world %d %.1f %s\n", x, y,s);
	return 0;
}
