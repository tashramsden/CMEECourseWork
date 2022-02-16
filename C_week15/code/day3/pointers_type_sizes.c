#include <stdio.h>

int main (void) {
	char *type_str[] = {"char",
						"int",
						"long",
						"double",
						"float",
						"long double",};

	char *base_phrase1 = "the size of the ";
	char *base_phrase2 = " data type";

	printf("%s%s%s: %zu\n", base_phrase1, type_str[0], base_phrase2, sizeof(char));
	printf("%s%s%s: %zu\n", base_phrase1, type_str[1], base_phrase2, sizeof(int));
	printf("%s%s%s: %zu\n", base_phrase1, type_str[2], base_phrase2, sizeof(long));
	printf("%s%s%s: %zu\n", base_phrase1, type_str[3], base_phrase2, sizeof(double));
	printf("%s%s%s: %zu\n", base_phrase1, type_str[4], base_phrase2, sizeof(float));
	printf("%s%s%s: %zu\n", base_phrase1, type_str[5], base_phrase2, sizeof(long double));
	return 0;
}
