#include <stdio.h>

void count_to_10(int i)
{
	if (i < 11) {
		printf("%i\n", i);
		count_to_10(++i);
	}
}

int main(void)
{
	int i = 0;
	count_to_10(i);

	return 0;
}
