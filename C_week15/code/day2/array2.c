#include <stdio.h>

void print_intarray(int integers[], int nelems)
{
    int i;
    for (i = 0; i < nelems; ++i) {
        printf("%i ", integers[i]);
    }
    printf("\n");
}


int main(void)
{
	int array1[] = {1, 2, 3, 4, 5, 6};
	int array2[] = {7, 8, 9};
	int array3[10];

	// array3 = array1 + array2; // This is invalid and won't compile
	
	// would have to do: (or use loop!)
	array3[0] = array1[0];
	array3[1] = array1[1];
	array3[2] = array1[2];
	array3[3] = array1[3];
	array3[4] = array1[4];
	array3[5] = array1[5]; // Notice that we stop at 5 on array 1
	array3[6] = array2[0]; // And we re-begin at 0 on array 2
	array3[7] = array2[1];
	array3[8] = array2[2];

	int i;
	for (i = 0; i < 9; ++i) {
		if (i < 6) {
			array3[i] = array1[i];
		} else {
			array3[i] = array2[i-6];
		}
	}

	print_intarray(array3, 9);


	return 0;
}
