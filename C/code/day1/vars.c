#include <stdio.h>

int main(void)
{
    int x; // x is variable 

    x = 0; // 0 is a constant literal
    
    printf("The value of x is: %i\n", x);
 
    float y = 1.2;

    // Integral type data 
    // 0000 : 0
    // 0001 : 1
    // 0010 : 2
    char c; // 1-byte
    int i; // normally 32-bit
    long int li;
    long long int lli;
    
    // Floating-point types
    float f;
    double d; // bigger float
    long double ld; 

    // Basic arithmetic operators:
    // +, -, *, /
    // % modulo gives remainder
    // use math library for powers   
   
    x = 1.9;
    
    printf("The value of x is: %i\n", x);
 
    return x; 
}


