#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void* my_malloc(size_t s) // to replace checks originally in main below - reusable
{
	void* new_mem = NULL;

	// new_mem = malloc(s); - can assign and check IN if statement
	if ((new_mem = malloc(s))) { // NOTE nested brackets
		memset(new_mem, 0, s); // initialises to all 0s
	} else {
		printf("Insufficient memory for requested operation.\n");
                exit(EXIT_FAILURE);
	}

	return new_mem;
}

int main(void)
{
	int* intblock;

	intblock = NULL; // macro from stdlib..?

	/*
	intblock = malloc(10 * sizeof(int)); // takes 1 arg - how big want memory in bytes 
	// what if malloc fails? - SHOULD check - rest of program might be depending on getting this memory
	if (intblock == NULL) {
		printf("Insufficient memory for requested operation.\n");
		// exit(-1); // exits whole program - return -1 - controlled program crash
		exit(EXIT_FAILURE); // using macro instead
	}
	*/

	// replace all of above with own function my_malloc
	intblock = my_malloc(10 * sizeof(int));

	if (intblock != NULL) {
		free(intblock);
		intblock = NULL;
	}
	
	// free(intblock);

	/* notes about free:
	 * - do not free memory that's already been freed
	 */

	return 0;
}
