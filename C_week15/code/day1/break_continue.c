#include <stdio.h>

int main(void)
{
	int i = 0;

	// break
	while(!i) {
		if (i == 0) {
			break; // terminates the loop
		}
		++i;
	}


	// continue
	for (i = 0; i < 10; ++i) {
		if (i % 2) {
			printf("%i is an even number\n", i);
			continue; // skip to next iter of the loop
		}
		printf("%i is an odd number\n", i);
	}


	return 0;
}
