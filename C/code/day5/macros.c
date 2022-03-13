#define PI 3.141592654

// could include entire expressio/operation
#define ALLBUTONE ((-1)^1) // entire macro definition in brackets

// NOTE: macros are "invisible" to debuggers!

// function-like macros
// eg to free a pointer and set it to NULL like:
// free(dataptr);
// dataptr = NULL;
#define CFREE(x) {free(x); x = NULL;}
// to free and clear a pointer, would write CFREE(dataptr);

