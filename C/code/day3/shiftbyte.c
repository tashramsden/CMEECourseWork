#include <stdio.h>
#include <stdlib.h>

void printbitz(int x)
{
	// currently prints bits backwards??? -maybe?
	int c = 0;
	unsigned mask = 1; // same as unsigned int
	while (mask) {
		if (mask & x) {
			printf("1");
		} else {
			printf("0");
		}
		++c;
		if (c == 8) {
			printf(" ");
			c=0;
		}
		mask = mask << 1;
	}
	printf("\n");
}

int main(void)
{
	int x;
	x = 88172666;

	unsigned char *p; // p is a pointer to a char

	//// p = &x; // assign the char pointer the address of x
	//// (as though this is an address to a char)
	// p = (unsigned char*)&x; // typecast to silence the compiler warning

	// below does same as typecast above
	// passing trhough void pointer means now no assumptions about size
	void *vp;
	vp = &x;
	p = vp;

	int i;
	// i = *vp; // this not allowed! compiler error!

	printbitz(x);
	// shift 3rd byte of x 3 to the left:
	p[2] = p[2] << 3;
	printbitz(x);

        // shift 3rd byte of x 3 to the right:
        p[2] = p[2] >> 3;
        printbitz(x);



	return 0;
}
