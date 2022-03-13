#include <stdio.h>
#include <string.h>
#include <ctype.h>

int base_to_bits(char c)
{
	if (c == 'A' || c == 'a') { // case insensitive
		return 1;
	}
	if (toupper(c) == 'C') { // makes c upper case - from ctype.h
		return 1 << 1;
	}
	if (toupper(c) == 'T') {
                return 1 << 2;
        }
        if (toupper(c) == 'G') {
                return 1 << 3;
        }
	if (c == '?') {
		return ~0;
	}

	// if not any of above:
        printf("Value %c is not a DNA base\n", c);
        return 0;
}

int main(void)
{
	char sp1_seq1[] = "ACCCGT";
	char sp1_seq2[] = "ACCCCT";
	char sp2_seq1[] = "ATTGCT";
	char sp3_seq1[] = "ACGCTT";

	// Want to get (uncorrected) genetic distance between each spp
	
	// Could loop over all pairwise comparisons: - doesn't take into account polymorphisms
	int i;
	int seqlen = strlen(sp1_seq1); // all same length here
	int dist_spp12 = 0;
	
	for (i = 0; i < seqlen; ++i) {
		if (sp1_seq1[i] != sp2_seq1[i]) {
			++dist_spp12;
		}
	}

	// OR - use bitwise comparisons 
	int sp1_seq[seqlen];
	int sp2_seq[seqlen];
	int sp3_seq[seqlen];

	memset(sp1_seq, 0, seqlen * sizeof(int));
        memset(sp2_seq, 0, seqlen * sizeof(int));
        memset(sp3_seq, 0, seqlen * sizeof(int));

	// convert spp1:
        for (i = 0; i < seqlen; ++i) {
                sp1_seq[i] |= base_to_bits(sp1_seq1[i]);
		//sp1_seq[i] = sp1_seq[i] | base_to_bits(sp1_seq2[i]);
		sp1_seq[i] |= base_to_bits(sp1_seq2[i]); // a |= x same as a = a | x

        }

	// convert spp2:
	for (i = 0; i < seqlen; ++i) {
		sp2_seq[i] |= base_to_bits(sp2_seq1[i]);
	}

	// convert spp3:
        for (i = 0; i < seqlen; ++i) {
                sp3_seq[i] |= base_to_bits(sp3_seq1[i]);
        }

	// Do all pairwise comparisons
	// sp1 vs sp2
	int dist = 0;
	for (i = 0; i < seqlen; ++i) {
		if (!(sp1_seq[i] & sp2_seq[i])) {
			++dist;
		}
	}
	printf("Distance between sp1 and sp2: %i\n", dist);

	// sp1 vs sp3
        dist = 0;
        for (i = 0; i < seqlen; ++i) {
                if (!(sp1_seq[i] & sp3_seq[i])) {
                        ++dist;
                }
        }
	printf("Distance between sp1 and sp3: %i\n", dist);

 	// sp3 vs sp2
        dist = 0;
        for (i = 0; i < seqlen; ++i) {
                if (!(sp3_seq[i] & sp2_seq[i])) {
                        ++dist;
                }
        }
        printf("Distance between sp3 and sp2: %i\n", dist);

	return 0;
}
