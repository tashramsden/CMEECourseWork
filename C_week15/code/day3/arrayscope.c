#include <stdio.h>

int doubler(int i)
{
	i = i * 2;

	return i;
}

void array_doubler(int arr[], int nelems)
{
	int i;
	for (i = 0; i < nelems; ++i) { // in python: for i in arr: ... C doesn't know how big arr is!!!
		arr[i] = doubler(arr[i]);
	}
}

//void print_intarray(int arr[], int nelems)
void print_intarray(int * arr, int nelems) // does same as above array vs pointer
{
	int i;
	for (i = 0; i < nelems; ++i) {
		printf("%i ", arr[i]);
	}
	printf("\n");
}

int main(void)
{
	int x = 7;
	int integs[5]; // integs is a reference type - pointer to the array

	// Initialise integs
	int i;
	for (i = 0; i < 5; ++i) {
		integs[i] = i + 1;
	}

	x = doubler(x);
	// If this not assigned back to x, x would not change
	// doubler does not have access to x memory, just gets copy
	
	printf("The value of x: %i\n", x);

	print_intarray(integs, 5);

	array_doubler(integs, 5);

	print_intarray(integs, 5);

	/* With arrays, even though result of doing array_doubler not assigned back to integs, the array has still been changed.
	 * array_doubler has access to integs memory - unlike above (x doubler)
	 * here, does not get copy of the array,
	 * gets a reference to the array's memory itself - POINTER
	 * array_doubler will directly alter original array
	 */

	return 0;
}
