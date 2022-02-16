#include <stdio.h>

#define MAX_NUMS_PRINTED 33

int main(void)
{
	int i;

	int nums_printed = 0;

	for (i = 1; nums_printed < MAX_NUMS_PRINTED; ++i) {
		if (i % 7 == 0 || i % 10 == 0) {
			++nums_printed;
			printf("Num %i: %i\n", nums_printed, i);
		}
	}

	return 0;
}
