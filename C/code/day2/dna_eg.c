#include <stdio.h>

int main(void)
{
	char A_ = (char)1;
	char C_ = (char)(1 << 1);
	char G_ = (char)(1 << 2);
	char T_ = (char)(1 << 3);

	char ret = 0;

	if (base == 'A' || base == 'a') {
		ret = A_;
	}
	else if (base == 'C' || base == 'c') {
		ret = C_;
	}
	else if (base == 'G' || base == 'G') {
		ret = G_;
	}
	else if (base == 'T' || base == 'T') {
		ret = T_;
	} else if (base == 'Y' || base == 'y') {
		ret = C_ | T_;
	}
	else if (base == 'R' || base == 'r') {
		ret = A_ | G_;
	}



	return 0;
}
