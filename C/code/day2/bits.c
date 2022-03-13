#include <stdio.h>

int main(void)
{
	// set all bits
	int allset = -1;

	// &
	int a = 98;
	int b = 118;
	int result = a & b;
	printf("Bitwise AND of 98 and 118: %i\n", result);

	// also set all bits with bitwise inverse
	allset = ~0;


	return 0;
}
