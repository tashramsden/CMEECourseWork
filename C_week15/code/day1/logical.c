#include <stdio.h>
#include <stdbool.h>

int main(void)
{
//    _Bool x = 0;
 
    bool x = false; // def: 0
    bool y = true; // def: 1 

    if (x) { // inexplicit check
        printf("x is true\n");
    }

    int i = 9;
    y = (i == 0); // y will be false/0
    if (i == 0) { // explicit check ==
        printf("i is false\n");
    } else {
        print("i is true\n");
    }

    if (!i) {
       printf("i is false\n");
    }

    // Binary logical operators
    // var && var : AND
    // var || var : OR

    // ternary conditional: x ? y : z 
    // x is an expression, if true get y else get z (basically an if else)
 
    return 0;
}
