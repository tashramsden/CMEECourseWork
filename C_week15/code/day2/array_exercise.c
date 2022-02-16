#include <stdio.h>

int main(void)
{
	int i = 3;
	int myarray[5];

	myarray[3] = 2;

	printf("The value at index %i in my array: %i\n", i, myarray[i]);

	printf("The square of the value at index %i in my array: %i\n", i, myarray[i]*myarray[i]);

	return 0;
}
