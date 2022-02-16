#include <stdio.h>
#include <stdlib.h>

// enums = assign alias to integers 0...n 
// eg could use simple numbering system for ecah data type (this file) (or error messages in enums.c)
// This might allow us to be lazy and not have to program any routines that do type-checking on input data. Instead, we can leave the onus on the user to specify their input data type.

//enum data_type {int_type, float_type, double_type, char_type};
enum data_type {int_type = 1, float_type, double_type, char_type};
// set to start at 1, so that if no user value supplied dt remains set to 0 -error code is returned

int main(void)
{
/* THIS WON'T RUN - JUST EGs
	data_type dt = 0;

	// ... some user input is parsed here
	// ... dt is assigned by some user input if provided

	if (dt == int_type) {
		calculate_asint(input_datum.as_int);
	else if (dt == float_type) {
		calculate_asfloat(input_datum.as_float);
	}
	else if (dt == double_type) {
		calculate_asdouble(input_datum.as_double);
	}
	else if (dt == char_type) {
		calculate_aschar(input_datum.as_char);
	}
	else {
		printf("Error: no specified datatype\n");
		exit(-1); // Quit the program and return an error code
	}


*/
	return 0;
}

