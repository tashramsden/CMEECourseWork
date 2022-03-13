#include <stdio.h>

void print_intarray(int integers[], int nelems)
{
    int i;
    for (i = 0; i < nelems; ++i) {
        printf("%i ", integers[i]);
    }
    printf("\n");
}

void binary_search(int search, int array[], int nelems)
{
	int first = 0;
	int last = nelems - 1;
	int middle = (first+last) / 2;

	while (first <= last) {
		if (array[middle] < search) {
			first = middle + 1;
		} else if (array[middle] == search) {
			printf("%i found at index: %i\n", search, middle);
			break;
		} else {
			last = middle - 1;
		}
		middle = (first+last)/2;
	}
	if (first > last) {
		printf("%i isn't in the array!\n", search);
	}

}

int main(void)
{

	int array[13] = {123, 747, 768, 2742, 988, 1121, 109, 999, 727, 1030, 999, 2014, 1402};

	print_intarray(array, 13);

	int temp;
	int i, j;
	for (i = 0; i < 13; ++i) {
		for (j = i + 1; j < 13; ++j) {
			if (array[j] < array[i]) {
				temp = array[i];
				array[i] = array[j];
				array[j] = temp;
			}
		}
	}

	print_intarray(array, 13);

	binary_search(768, array, 13);
	binary_search(123, array, 13);
	binary_search(3, array, 13);


	return 0;
}
