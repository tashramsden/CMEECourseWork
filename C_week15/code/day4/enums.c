#include <stdio.h>

enum my_error_t {
	MYPROG_SUCCESS,
	UNEXPECTED_NULLPTR,
	OUT_OF_BOUNDS,

	MY_ERROR_MAX // A useful pattern: add new enum defs above
};

int main(void)
{
	// exit(-1) // would quit program
	
	enum my_error_t err;

	const int arraymax = 5;
	int values[arraymax];
	int userval = 5;

	if (userval < arraymax) {
		printf("Value %i is: %i\n", userval, values[userval]);
	} else {
		err = OUT_OF_BOUNDS;
	}

	return err;
}
