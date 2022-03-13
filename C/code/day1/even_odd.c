#include <stdio.h>

int main(void)
{
	int i;

	for (i = 0; i < 10; ++i) {
		if (i % 2 == 0) {
			printf("%i is an even number\n", i);
			continue;
		}
		
		printf("%i is an odd number\n", i);
	}

	return 0;
}
