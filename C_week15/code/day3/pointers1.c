#include <stdio.h>
#include <stdlib.h>

void doubler(int* i) // function that takes a pointer to an int
	// can also write above as (int *i) - means same, less clear
{
	// when this func took an int
	// i = i * 2;
	// return i;
	
	// now express this using pointers
	*i = *i * 2; // *i is the VALUE in the pointer address i
	// (i is a pointer)
	// will change the value in the address pointer to by i
	// don't need to return anything - IS changing the value in i
}	

int main(void)
{
	int x;
	int* xp; // declare pointer

	// int* ptr1, ptr2; // this declares 1 pointer to int and 1 int! (NOT 2 ptrs)

	xp = NULL; 

	xp = &x; // initialise pointer to address of x

	printf("x before initialisation: %i\n", x);

	// use pointer to init x
	*xp = 7;

	printf("x after initialisation: %i\n", x);

	doubler(xp);

	printf("x after doubler using pointers: %i\n", x);


	// arrays and pointers
        int integs[] = {1, 2, 3, 4, 5};

        // *xp == xp[0]; // can use array syntax on pointers

        int *z; // z is a pointer
        z = &integs[0];  // z points to the array integs
        z = integs; // equivalent to above

        printf("third element of the array: %i\n", *(z + 2) );
	// z is pointer to start of array, add 2 to get pointer to third element, dereference whole thing to get VALUE in third element
	printf("third element of the array: %i\n", z[2] ); // equivalent


	return 0;
}

