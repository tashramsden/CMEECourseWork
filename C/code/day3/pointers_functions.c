#include <stdio.h>

int *first_odd_num(int* oddsandevens, int arraymax)
{
	int i = 0;
	while (!(*oddsandevens % 2) && i < arraymax) {
		++oddsandevens;
		++i;
	}
	
	return oddsandevens;
}

int *first_odd_num2(int* oddsandevens, int arraymax)
{
    int i = 0;
    
    while (!(oddsandevens[i] % 2) && i < arraymax) {
        ++i;
    }
    
    return &oddsandevens[i];
}

int main (void)
{
    int arraymax = 5;
    int intarray[] = {2, 4, 6, 7, 5};
    int *result = NULL;
	  
    result = first_odd_num(intarray, arraymax);
    printf("first odd: %i\n", *result);
	  
    result = first_odd_num2(intarray, arraymax);
    printf("first odd 2: %i\n", *result);
	  
    return 0;
 }

