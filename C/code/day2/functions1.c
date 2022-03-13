#include <stdio.h>

int x = 1;
int y; // global scope

int main(void)
{
    int x = 4;

    {
        int x = 5;
    }

    printf("The value of x: %i\n", x);
    printf("The value of y: %i\n", y);

    return 0;
}
