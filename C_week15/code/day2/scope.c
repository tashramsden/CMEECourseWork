#include <stdio.h>

int main(void)
{
    int i = 5;
    
    printf("i in scope of main(): %i\n", i);

    {
    	int i = 10;
	printf("i in local scope: %i\n", i);
    }
    
    if (i) {
        printf("This i is %i\n", i);	
    }
    
    if (i) {
        int i = 50;
	printf("A new automatic i: %i\n", i);
    }
    
    return 0;
}
