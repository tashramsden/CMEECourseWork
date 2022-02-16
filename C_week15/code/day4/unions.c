#include <stdio.h>

// unions declared w similar syntax as structs
// generally use single "memory footprint" to store their data
// can have many members - but only one "active" at a time

union input_datum {
	int as_int;
	float as_float;
	double as_double;
	char as_char;
};

int main(void)
{

	return 0;
}
