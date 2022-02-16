#include <stdio.h>

int main(void)
{
        int numbers[5];
        int* nptr;

        nptr = numbers;
        *(nptr + 3); // can use pointer arithmetic(here)/array indexing(below) to do same thing
        nptr[3];

	return 0;
}
