#include <R.h> // The R library for C
#include <Rdefines.h> // The R library for defining variables in C

SEXP double_me(SEXP x)
{
  SEXP result;
  PROTECT(result = NEW_INTEGER(1));
  *(INTEGER(result)) = *(INTEGER(x)) + *(INTEGER(x));
  UNPROTECT(1);
  return result;
}
