#include <stdio.h>

int main(void)
{
	int a = 2;
	int b = 4;
	int c = 0;

	int *a_ptr = &a; // reminder: &a reads "the address of a"
	int *b_ptr = &b;
	int *c_ptr = &c;

	*c_ptr = *a_ptr + *b_ptr;
	// same as:
	// c = *a_ptr + b;
	// *c_ptr = a + *b_ptr;
	// *c_ptr = *a_ptr + b;
	// *c_ptr = a + b;
	// (i.e. can mix these in any way!)

	printf("The result of using pointers for arithmetic: %i\n", *c_ptr);
	printf("Or: %i\n", c);

	return 0;
}
