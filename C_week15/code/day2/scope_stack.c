#include <stdio.h>

void index_through_array(int mynumbers[5], int index)
{
    while (index < 5) {
        printf("Element %i: %i\n", index, mynumbers[index]);
        ++index;    // Notice we are incrementing the variable 
                    //index that was passed in.
    }

    printf("Value of index at end of function call: %i\n", index);
    return; // Function has no return value
}

int main (void)
{
    int index = 0;
    int mynums[] = {19, 81, 4, 8, 10};

    printf("Value of i before function call: %i\n", index);
    index_through_array(mynums, index); // Pass index to this function
    printf("Value of i after function call: %i\ni", index);

    return 0;
}
