#include <stdio.h>
#include <string.h>
#include <ctype.h> // for toupper()

char base_to_bits(char base)
{
        char A_ = (char)1;
        char C_ = (char)(1 << 1);
        char G_ = (char)(1 << 2);
        char T_ = (char)(1 << 3);

	char ret = 0;

	if (toupper(base) == 'A') {
		ret = A_;
	}
	else if (toupper(base) == 'C') {
		ret = C_;
	}
	else if (toupper(base) == 'G') {
		ret = G_;
	}
	else if (toupper(base) == 'T') {
		ret = T_;
	}
	else if (toupper(base) == 'Y') { // pYramidine 
		ret = C_ | T_;
	}
	else if (toupper(base) == 'R') { // puRine
		ret = A_ | G_;
	} 
	else if (base == '?') {
		ret = ~0;
	} else {
		// if none of the above!
		printf("Value %c is not a DNA base\n!", base);
		ret = 0;
	}
	return ret;
}

void print_bits(char x) // prints bits backwards...!
{
	int c = 0;
	unsigned char mask = 1;
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
	char seq[] = "CATAAACCCTGGCGC";

	int seqlen = strlen(seq);
	printf("seqlen: %i\n", seqlen);

	char binary_seq[seqlen];

	memset(binary_seq, 0, seqlen * sizeof(char));

	int i;
	for (i = 0; i < seqlen; ++i) {
		// printf("Base: %c\n", seq[i]);
		binary_seq[i] |= base_to_bits(seq[i]);
	}

	// binary_seq and seq and same size as both char type
	//int binary_len = sizeof(binary_seq);
	//printf("Len: %i\n", binary_len);	
	
	for (i = 0; i < seqlen; ++i) {
		print_bits(binary_seq[i]);
	}
				


	//printf("Binary seq: %i", binary_seq);


	return 0;
}
