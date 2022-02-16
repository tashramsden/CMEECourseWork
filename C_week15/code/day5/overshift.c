#include <stdio.h>

int main(void)
{
	signed char schar; // "signed" not required - just for clarity
	unsigned char uchar;

	signed char sres;
	unsigned char ures;

	// char always 1 byte
	schar = 1; // binary: 00000001
	uchar = 1; // binary: 00000001

	// printf("%c\n", schar); // shows nothing - int 1 as a char is nothing
	
	printf("%i\n", schar);
	printf("%u\n", uchar);

	// shift by 8 to the left - shift the set bit out of the byte -> 0
	sres = schar << 8;
	printf("%i\n", sres);
	ures = uchar << ((char)8);
        printf("%u\n", ures);

	// shift 1 to the right - same get 0
        sres = schar >> ((char)1);
	printf("%i\n", sres);
        ures = uchar >> ((char)1);
        printf("%u\n", ures);

	// move set bit over to most sig position (left) - for signed char - becomes negative
	sres = schar << ((char)7);
        printf("%i\n", sres);


        signed char schar2 = 255; // signed has lower absolute value than unsigned - most sig bit for sign
        unsigned char uchar2 = 255; // binary: 11111111

	sres = schar2 << ((char)8);
        printf("%i\n", sres);
        ures = uchar2 << ((char)8);
        printf("%u\n", ures);

	// now for signed get -1 (shifting signed values can be problem ~undefined ish)
	sres = schar2 >> ((char)8);
        printf("%i\n", sres);
        ures = uchar2 >> ((char)8);
        printf("%u\n", ures);

	return 0;
}
