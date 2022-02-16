#include <stdio.h>

int main (void)
{
	int i = 0;
	int value = 0;
	int max_nums = 5;
	int numbers[] = {87, 22, 34, 52, 3};
	int *nptr = NULL;
	
	nptr = numbers;
	
	// We can obtain a member of numbers[] three different ways:
	
	for (i = 0; i < max_nums; ++i) {
		
		printf("For i = %i:\n", i);
		
		value = numbers[i];
		printf("Indexing array directly: %i\n", value); 
		
		value = *(nptr + i);
		printf("Pointer arithmetic: %i\n", value);
		
		value = nptr[i];
		printf("Array-style indexing a pointer: %i\n", value);
		
		printf("\n");
	}
}
