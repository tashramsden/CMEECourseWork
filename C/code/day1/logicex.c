#include <stdio.h>
#include <string.h>

int main(void)
{
    int a, b, c, d;

    a = 0;
    b = 32;

    printf("The result of !a: %i\n", !a); // a == 0;
    printf("The result of !b: %i\n", !b);

    char message[] = "The quick brown fox\n";

    // strchr
    // char* strchr(const char *str, int c)
    // returns char
    // searches for a char in a string
    // if found - returns position, if not returns null/0

    char s = 'q';
    if (!strchr(message, s)) {
        printf("Character %c does not exist in the message:\n %s\n", s, message);
    } else {
        printf("Character %c found in message\n", s);
    } 

    s = 'E';
    if (!strchr(message, s)) {
        printf("Character %c does not exist in the message:\n %s \n", s, message);
    } else {
        printf("Character %c found in message\n", s);
    }

    a = 0;
    b = 2;

    a && b; // evaluates to false
    a || b; // true
    !a && b; // true
    a || !b; // false

    return 0;
}
