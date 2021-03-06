#include <stdio.h>
#include <ctype.h>

float divide(float num, float denom); // Function prototype

/* Can either have prototype here/actual function
- but divide MUST be declared before main
Generally better to just have all functions at top, main last
*/

float divide(float num, float denom)
{
    float res; // Automatic local variable

    res = num / denom;

    return res;
}

// CAN return void/nothing
void print_alnum_character(char c)
{
    if (!isalnum(c)) {
        printf("Character is not alphanumeric!\n");
        return;
    }

    printf("%c", c);

    return;
}

int main(void)
{
    int x, y;
    float f;

    x = 7;
    y = 3;

    f = x / y;

    printf("The result of int division: %f\n", f);

    f = divide(x, y);

    printf("The result of division using a function: %f\n", f);

    print_alnum_character('[');
    printf("\n");
    print_alnum_character('6');
    printf("\n");

    return 0;
}

