#include <stdio.h>

int factorial(int n)
{
    if (!n) { // If n == 0, this true and returns 1
        return 1;
    }

    // If n anything but 0, call factorial again recursively
    return n * factorial(n - 1);
}

int main(void)
{
    int i;
    int r;
 
    i = 3; 

    r = factorial(i);

    printf("%i factorial is: %i\n", i, r);

    return 0;
}
