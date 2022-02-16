#include <stdio.h>

int main (void)
{
  int x = 1;
  printf("The value of x: %i\n", x);

  char c = 'a';
  printf("The value of c: %c\n", c);

  float f = 1.1;
  printf("The value of f: %f\n", f);

  double d = 1.1;
  printf("The value of d: %e\n", d);

  // "incompatible" types
  int y = 'a';
  printf("The value of the int y, 'a': %i\n", y);

  return 0;
}
