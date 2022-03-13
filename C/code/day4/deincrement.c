#include <stdio.h>

int main(void)
{
	int i;

	int numbers[] = {1, 2, 3, 4, 5};

	// Increment operator
	i++; // or ++i;

	// Deincrement
	i--; // or --i;
	// useful for eg looping through something backwards, eg phylogenies etc

	// Print elements forwards:
	for (i = 0; i < 5; ++i) {
		printf("%i ", numbers[i]);
	}
	printf("\n");

	// Print elements backwards:
	for (i = 4; i >= 0; --i) { // i-- works here too
		printf("%i ", numbers[i]);
	}
        printf("\n");

        // does same:
	for (i = 5; i--; ) { // see notes
                printf("%i ", numbers[i]);
        }
        printf("\n");



	return 0;
}
