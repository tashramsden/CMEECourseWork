#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	int i;
	int num; // number given by user

	// Expect one arg from user, it should be a non-zero int
        if (argc != 2) {
                printf("ERROR: program requires 1 (and only 1) argument! (an int)\n");
                return -1;
        }
        // check its an int (BUT args taken as strings)
        num = atoi(argv[1]); // turn string into int (from stdlib.h)
        if (num == 0) {
                printf("ERROR: input must be non-zero integer\n");
		return -1;
        }

	int is_prime = 1;
	for (i = 2; i < num; ++i) {
		if (num % i == 0) {
			is_prime = 0;
		}
	}
	
	if (!is_prime) {
		printf("%i is not a prime!\n", num);
	} else {
		printf("%i is a prime!\n", num);
	}


	return 0;
}
