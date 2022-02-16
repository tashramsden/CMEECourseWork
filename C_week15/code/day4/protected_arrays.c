#include <stdio.h>

// good practice - library of functions for protected arrays - safer, less error-prone code

// wrapping an array in a struct
typedef struct {
    int maxvals;     // The maximum size the array can have (according to the amount of memory allocated)
    int numvals;     // The number of actual values written to the array (you might choose to have fewer values than you need)
    int head;        // If you are sequentially using elements of an array, you can keep track of the last value here
    int *entries;    // A pointer to ints that can be dynamically allocated according to size needs
} intarray_t;        // Our new variable type: intarray_t.


// create and destroy an intarray
intarray_t *create_intarray(int maxsize)
{
    intarray_t *newarray_ptr = NULL;
    
    newarray_ptr = (intarray_t*)calloc(sizeof(intarray)); // Allocates memory for an intarray and passes the address back to newarray_ptr

    // Now we need to set the variables inside the struct at newarray_ptr
    newarray_ptr->entries = (int*)calloc(maxsize, sizeof(int));
    newarray_ptr->maxvals = maxsize;
    newarray_ptr->head = 0;
    newarray_ptr->numvals = maxsize;
    
    return newarray_ptr;
}

int destroy_intarray(intarray_t *oldarray)
{
    // Always do a check that a pointer to valid memory has been passed, otherwise free() will crash
    if (oldarray) {
        free(oldarray->entries);
        oldarray->maxvals = 0;
        oldarray->numvals = 0;
        oldarray->head = 0;
        return 0;
    }
    else {
        return -1; // Here indicating an error
    }
}


// writing to protected arrays
int append_integer(intarray_t *myints, int newval)
{
    // The first thing we do is check that there's room to append an integer
    if (myints->numvals < myints->maxvals) {
        myints->entries[numvals] = newval;
        ++myints->numvals;
        return 0;
    }
    else {
        return -1;
    }
}


int write_to_intarray(intarray_t *myints, int newval, int place)
{
    if (place < myints->maxvals) {
        myints->entries[place] = newval;
        if (place >= myints->numvals) {
            myints->numvals = place + 1;
            return 0;
        }
    }
    else {
        return -1;
    }
}


// return value from intarray
int get_int_from_array(intarray_t *myints, int place)
{
    if (place < myints->maxvals) {
        return myints->entries[place];
    }
    else {
        return 0; // See exercise for potential improvements to this
    }
}






