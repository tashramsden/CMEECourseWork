#include <stdio.h>

int main(void)
{

    unsigned long x = sizeof(long);
    printf("The size of long is: %lu\n", x);

    float y = sizeof(float);
    printf("The size of float is: %f\n", y);

    double z = sizeof(double);
    printf("The size of double is %f\n", z);

    long double w = sizeof(long double);
    printf("The size of long double is: %Lf\n", w);


    return 0;
}
