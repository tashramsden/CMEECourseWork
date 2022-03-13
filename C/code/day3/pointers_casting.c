#include <stdio.h>

int main(void)
{
    int i, j;
    int *ip1, *ip2;
    float y, z;
    float *fp1, *fp2;
    
    i = 42;
    ip1 = &i;
    ip2 = &j;

    // We can assign from i to j through their pointers
    *ip2 = *ip1;

    printf("We expect this number to be %i: %i\n", i, j);

    // We can do a similar thing with floats
    y = 3.141593;
    
    fp1 = &y;
    fp2 = &z;
    
    *fp2 = *fp1;

    printf("We expect this number to be: %f: %f\n", y, z);

    // Now we know that passing from a float to an int will cause truncation
    i = *fp1;
    // We expect this result to be 3 (the stuff after the decimal gets truncated without rounding)
    printf("i is now: %i\n", i);
    
    // The same will be true even if we do this:
    i = (int)*fp1;
    printf("i is now: %i\n", i);

    // But what happens when we do this?
    i = * (int *)fp2;
    printf("i is now: %i\n", i);

    return 0;
}
