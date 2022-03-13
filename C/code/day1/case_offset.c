#include <stdio.h>

int main(void)
{
	char a = 'a';
	char b = 'A';

	char case_offset;

	case_offset = a - b;

	printf("Case offset: %i\n", case_offset);

	return 0;
}
