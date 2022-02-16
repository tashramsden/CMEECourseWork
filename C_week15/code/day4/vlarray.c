#include <stdio.h>
#include <stdlib.h>

int* create_int_array(int nelems) 
{
	// int newarray[nelems]; // this not successful 
	// newarray is created in this function
	// stack w this memory lost after function call

	int* newarray;

	// declaration of malloc: void* malloc(size_t n);
	newarray = malloc(sizeof(int) * nelems);
	// newarray = calloc(nelems, sizeof(int)); // does same as malloc - takes num elements and size, plus allocates all elems to 0 - safer

	return newarray;
}

int main(int argc, char *argv[]) // can also write **argv rather than *argv[]
{
	int i;
	int nelems;

	/*
	for (i = 0; i < argc; ++i) {
		printf("argument %i: %s\n", i, argv[i]);
	};
	*/

	// Expect one arg from user, it should be a non-zero int
	if (argc != 2) {
		printf("ERROR: program requires 1 (and only 1) argument! (an int)\n");
		return -1;
	}
	// check its an int (BUT args taken as strings)
	nelems = atoi(argv[1]); // turn string into int (from stdlib.h)
	// atoi retruns 0 if gets an erronious value
	// problem if string passed is 0...! but here fine, don't have array size 0
	if (nelems == 0) {
		printf("ERROR: input must be non-zero integer\n");
	}

	// int myintegers[nelems]; // variable sized array - based on user input

	int* myintegers;
	myintegers = create_int_array(nelems);

	int* oldints; // create another pointer to store this orig pointer before overwriting below
	oldints = myintegers;

	for (i = 0; i < nelems; ++i) {
		myintegers[i] = i + 1;
		printf("%i ", myintegers[i]);
	}
	printf("\n");

	// repeat above - demonstrate  memory leak
	myintegers = create_int_array(nelems);
	// now contains "garbage" - doesn't have same address as first myintegers
	// hasn't overwritten original myintegers - just overwritten the pointer
	
        for (i = 0; i < nelems; ++i) {
                printf("%i ", myintegers[i]);
        }
        printf("\n");

        for (i = 0; i < nelems; ++i) {
                printf("%i ", oldints[i]); // the old array still exists - only orig pointer been overwritten
        }
        printf("\n");


	free(myintegers); // free the memory
	free(oldints);

	return 0;
}
