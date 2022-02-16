#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void *my_malloc(size_t size_of_data)
{
     void *new_mem;
	
     if ((new_mem = malloc(size_of_data))) {
		     memset(new_mem, 0, size_of_data); // Look up memset() to see how this function works
		     }
     else {
         printf("Error: unable to allocate sufficient memory\n");
	 exit(EXIT_FAILURE);
     }
	
     return new_mem;
}

// malloc and calloc, prototypes:
// void *malloc(size_t size);
// void *calloc(size_t num_items, size_t size_of_elements);
// return pointer to some memory of desired size

// size_t = type - is usually an unsigned long int
// used to express size of data type in num of bytes
// can get this num using sizeof()

// eg find diff (if any) in size of int and char 
int main (void)
{
    printf("Size of char: %zu bytes\n", sizeof(char));
    printf("Size of int:  %zu bytes\n", sizeof(int));

    // eg if we needed space for 10 int and 10 char from malloc/calloc - the 10 ints would take up 4x as much space

    // memory for up to 20 ints:
    int * _20_ints = NULL;

    _20_ints = (int*)malloc(20 * sizeof(int)); // typecast the return value to tell the compiler what we want

    // or using calloc:
    _20_ints = (int*)calloc(20, sizeof(int)); // sets all bits to 0 too - safer


    // eg some code to create enough memory for a nucleotide seq of arbitrary length:
    int num_sites = 0;
    char *nucleotide_sites = NULL; // A pointer to nothing.
    /* ... some code that obtains num_sites value from some input data ... */ 
    nucleotide_sites = (char*)calloc(num_sites, sizeof(char));


    // Heap memory (unlike stack) persists until it is freed/program ends
    // should always return memory once done w it
    // free() takes any pointer that points to valid memory
    // but if that memory already freed - crash
    // to avoid, use wrapper:
    int * something_ptr;
    if (something_ptr) {
	    free(something_ptr);
	    something_ptr = NULL; // reset the pointer to a null value
    }


    // Allocation failure
    // malloc/calloc can fail - should check successful before continuing
    if (!(nucleotide_sites = (char*)calloc(num_sites, sizeof(char))) ) {
	    printf("Error: unable to allocate sufficient memory\n");
	    exit(EXIT_FAILURE);
    }

    // or do this in a custom wrapper - see my_malloc function at top!


    // Memory leaks
    // eg overwrite pointer to memory - that memory still exists but not accessible
    // use 2 pointers - one to start, one for incrementing etc
    // free memory when no longer needed
    // free all memory after using - for every allocation of memory, also have function to free it
    
    // Dangling pointers
    // once memory freed, should set pointers to it to NULL
    // otherwise pointer refers to garbage memory w no meaning

    return 0;
}


