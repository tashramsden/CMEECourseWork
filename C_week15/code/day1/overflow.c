#include <stdio.h>
#include <unistd.h> // not portable - "Unix standard"

int main(void)
{
    short int i = 1; // try signed and unsigned

    do {
        i *= 2; // try w *2 or +1 etc
        printf("%i\n", i); 
        sleep(1); // from unistd.h - pause program so that first results seen
    } while (1); // just have while(1) to keep going -flipping from +ve and -ve still get - OVERFLOW
// or while (i > 0)

    return 0; 

}
