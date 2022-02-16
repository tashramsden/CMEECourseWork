#include <stdio.h>
#include <stdlib.h>

#include "calc.h"

int do_operation(float a, float b, char operator)
{
	if (operator == '+') {
		printf("%f\n", add_float(a, b));
		return 0;
	}
	if (operator == '-') {
                printf("%f\n", sub_float(a, b));
		return 0;
        }
	if (operator == 'x') {
                printf("%f\n", mult_float(a, b));
		return 0;
        }
	if (operator == '/') {
                printf("%f\n", div_float(a, b));
		return 0;
        }

	printf("Operator %c not recognised!\n", operator);
	return 1;
}

int main(int argc, char *argv[])
{
	int ret = 1; // test-driven development - when everytihng works return 0
	float op1, op2;
	char operator;

	// This program is a calculator that will take
	// three inputs (arguments) from the user:
	// 1. An operand
	// 2. An operator
	// 3. An operand
	
	if (argc == 4) {
		// Number of inputs correct
		op1 = atof(argv[1]); // gets arg1, returns a float
		op2 = atof(argv[3]);
	
		operator = argv[2][0]; // first element of arg2 
		// arg will be a string, first element is a char
		
		ret = do_operation(op1, op2, operator);
		// ret will be updated to 0 if everything worked

	} else if (argc == 1) {
		printf("This is a calculator program written by:\n \
			Tash Ramsden\n \
			It takes three command line arguments. The usage is:\n \
			./program number operator number\n \
			(use 'x' for multiplication)\n");
	}

	return ret;
}
