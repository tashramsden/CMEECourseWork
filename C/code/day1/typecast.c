#include <stdio.h>

int main (void)
{
    int i1 = 2;
    int f1 = 7;
    int intres = 0;
    float fres = 0;

    printf("Assign mixed to int:               %i\n", intres = f1/i1);
    printf("Assign mixed to float:             %f\n", fres = f1/i1);
    printf("Assign mixed with const to float:  %f\n", fres = f1/2);

    // type cast
    fres = (float) f1 / i1;
    printf("%f\n", fres);


    // exercise
	int		a = 3;
	int		b = 2;
	int		c = 0;
	float	d = 0.0;

	c = a / b;
	d = (float) a / b; // w/o typecast this would give int ans too

	printf("The result of a / b stored in c: %i\n", c);
	printf("The result of a / b stored in d: %f\n", d);


	float res;
	float myfloat = 2.5;
	printf("%f\n", res = myfloat - 2);
        printf("%f\n", res = 6 - myfloat);

	char mychar = 'a';
        printf("%f\n", res = myfloat - mychar);

    return 0;
}
