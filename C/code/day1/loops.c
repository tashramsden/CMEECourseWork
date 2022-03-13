#include <stdio.h>

int main(void)
{
    int x;

    // While loop...
    x = 0; 
    while (x < 10) {
        // x += 1;
        // equivalent to: x = x + 1;
        x++;
    } 

    // Do-while...
    x = 0;
    do {
        ++x; // does this before checking the condition below
    } while (x < 10);

    // For...
    for (x = 0; x < 10; ++x) { // all 3 args optional - eg could assign x=0 above for loop, could replace ++x with the same but in the loop
	    printf("%i\n", x);
    }

    // Goto: ...

    return 0;
}
