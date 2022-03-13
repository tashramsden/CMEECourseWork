#include <stdio.h>

int main(void)
{
    char sc; // by default signed
    unsigned char uc;

    int si;
    unsigned ui; // implied: unsigned int

    long li; // implied: long int
    unsigned long uli; // unsigned long int

    // bool cannot be signed - only 0/1 - definition of boolean 1 bit - no room for a sign

    // 0000 0001
    // 1000 0001 - signed type then this negative
    // signed/unsigned - can determine how overflow is defined

    return 0;
}
