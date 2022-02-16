#include <stdio.h>

#define MY_ARRAY_MAX 256 // macro - don't have to change throughtout code - just here

int main(void)
{
	int someints[MY_ARRAY_MAX];

	char i;
	int x;

	for (i = 0; i < MY_ARRAY_MAX; ++i) {
		//do something to something
	}

	i = 9; // Try this w 9 vs '9'
	x = 256;

	printf("The value in c: %i\n", i); // Interpret i as an int %i
	printf("The value in c: %c\n", i); // Interpret i as a char %c
	printf("The value in x: %i\n", x);	

	i = x;
	printf("The value in c: %i\n", i); // int is bigger data type than char - get overflow trying to write 256 into char
	// In single unsigned byte (char) - max value is 255

	return 0;
}
