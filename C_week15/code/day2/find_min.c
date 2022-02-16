#include <stdio.h>

int main(void)
{
	int nums[] = {123, 747, 768, 2742, 988, 1121, 109, 999, 727, 1030, 999, 2014, 1402};

	int min_num = nums[0];

	int i;
	for (i = 0; i < 13; ++i) {
		if (nums[i] < min_num) {
			min_num = nums[i];
		}
	}

	printf("Minimum number: %i\n", min_num);


	return 0;
}
