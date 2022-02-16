#include <stdio.h>
#include <string.h>

void print_strarray(char string[], int nelems)
{
    int i;
    for (i = 0; i < nelems; ++i) {
        printf("%c", string[i]);
    }
    printf("\n");
}

int main(void)
{
	char str1[] = "The quick brown fox ";
	char str2[] = "jumped over the lazy dog";

	int len_str1 = strlen(str1);
	//printf("Length str1: %i\n", len_str1);
	int len_str2 = strlen(str2);
        //printf("Length str2: %i\n", len_str2);

	int tot_length = len_str1 + len_str2;
	char result[tot_length];
        //printf("Length tot: %i\n", tot_length);
	
	int i;
	for (i = 0; i < tot_length; ++i) {
		if (i < len_str1) {
			result[i] = str1[i];
		} else {
			result[i] = str2[i - len_str1];
		}
	}

	print_strarray(result, tot_length);

	return 0;
}
