#include <stdio.h>
#include <string.h>

void reverse_string(int str_len, char mystr[])
{
	int s;
        printf("Reversed string: ");
        for (s = str_len; s >= 0; --s) {
                printf("%c", mystr[s]);
        }
        printf("\n");

}

void check_palindrome(int str_len, char mystr[])
{
	int b;
        int c;
        int is_palind = 1;
        for (b = 0; b < str_len; ++b) {
                c = str_len - 1 - b;
                if (mystr[b] != mystr[c]) {
                        is_palind = 0;
                }
        }
        if (!is_palind) {
                printf("Not a palindrome!\n");
        } else {
                printf("You've found a palindrome!\n");
        }
}

int main(int argc, char *argv[])
{

	if (argc != 2) {
		printf("This program needs an input: a string to be reversed\n");
		return -1;
	}

	int str_len = strlen(argv[1]);
	// printf("String len: %i\n", str_len);

	char mystr[str_len];

	int i;
	for (i = 0; i < str_len; ++i) {
		mystr[i] = argv[1][i];
	}	
	printf("Original string: %s\n", mystr);

	reverse_string(str_len, mystr);
	check_palindrome(str_len, mystr);


	return 0;
}
