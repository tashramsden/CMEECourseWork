#include <stdio.h>

int main(void)
{
	// eg consider some binary presence/absence data across 8 spp at 2 sites:
	// (assuming each array position corresponds to a sp)
	int site1[] = {0, 0, 1, 1, 0, 1, 1, 1};
	int site2[] = {1, 1, 0, 1, 0, 0, 1, 1};

	// check if any spp in common using loop
	for (i = 0; i < nspp; ++i) {
		if (site1[i] == 1 && site2[i] == 1) {
			return 1;
		}	
	}	

	// do the same (but much faster) w bitwise &
	if (site1 & site2) {
		return 1;
	}

	return 0;
}
