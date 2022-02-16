#include <stdio.h>

// const int arraymax = 10;

void print_intarray(int integers[], int nelems)
{
    int i;
    for (i = 0; i < nelems; ++i) {
	printf("%i ", integers[i]);
    }
    printf("\n");
}

int main(void)
{
    int x;
    int x_1[1]; // Uses same amount of memory as above - access differently
   
    const int arraymax = 10;

    int myarray1[arraymax]; // Explicit sizing of array
    int myarray2[] = {7, 9, 21, 55, 199191, 4, 18}; // Implicit size based on declared contents

    // arraymax = 10; - not allowed - set as constant

    myarray1[0] = 0;
    myarray1[1] = 0;
    myarray1[2] = 0;

    x = myarray1[2];

    // Fill myarray1 w zeros
    for (x = 0; x < arraymax; ++x) {
         myarray1[x] = 0;
    }

    printf("After initialisation: \n");
    print_intarray(myarray1, arraymax);


    // Out by 1/out of bounds bugs - don't get error but not good!
//    myarray1[5]; // This is a BUG! Get warning (with -Wall) this index doesn't exist - get garbage value
//    printf("A value from outside the array: %i\n", myarray1[5]); // This is also a BUG!

    // gcc compiler also allows initialising array w all 0s like:
    int another_array[5] = {0};

    return 0;
}
