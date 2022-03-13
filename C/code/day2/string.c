#include <stdio.h>
#include <string.h>

int main(void)
{
    // strings are just arrays of chars w a terminating null char

    char chars[] = {'H', 'e', 'l', 'l', 'o', '\0'}; // C strings - generally not use - unless explicitly null terminated as here they do not have null termination - keeps going
    char hellomsg[] = "Hello"; // String representation - null terminated by default

    printf("The length of chars: %i\n", strlen(chars));
    printf("The length of hellomsg: %i\n", strlen(hellomsg));

    printf("The second letter in Hello is: %c\n", hellomsg[1]);

    return 0;
}
