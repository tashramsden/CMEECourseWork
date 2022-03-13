#include <stdio.h>
#include <string.h> // functions for working w byte arrays/strings

int main(void)
{
	// Write a program to determine byte width of unsigned long int

	int i;
	char chars[256]; // more than enough - hack - going to write longs into chars - bigger so leave plenty of memory - avoid overflow
	unsigned long longs[2];

	longs[0] = 0UL; // All bits 0/unset
	longs[1] = ~0UL; // All bits set (1's complement of 0)

	memcpy(chars, longs, sizeof(unsigned long)*2); // mem copy, ie copy longs into chars (size of 2 longs) (longs and chars are both arrays)
	// chars and longs now identical byte for byte
	// copied longs into chars so that each byte can be looped through:
	i = 0;
	while (chars[i] == 0) { // counts how many bytes = 0 (ie length of a long in bytes - first long all bytes = 0, second long all bytes = 1)
		++i;
	}

	printf("The value of i: %i:\n", i);
	printf("The size of unsigned long: %lu\n", sizeof(unsigned long));
        
	// could do same w shorts - change above to declare short rather than long etc to work out length into i
       	printf("\nThe size of unsigned short: %lu\n", sizeof(unsigned short));

	return 0;
}
