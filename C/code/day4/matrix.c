// A program that illustrates the creation of
// a dynamic C matrix

#include <stdlib.h>
#include <stdio.h>

typedef struct int_matrix {
	int nrows;
	int ncols;
	int** data;
} int_matrix; // can wrap typedef around struct declaration

void initialise_matrix(int nrows, int ncols, int_matrix *m)
{
	int i;

	// (*m) - dereference m (a pointer to the struct)
	(*m).nrows = nrows;
	(*m).ncols = ncols;
        (*m).data = calloc(nrows, sizeof(int*));
        for (i = 0; i < nrows; ++i) {
                (*m).data[i] = calloc(ncols, sizeof(int));
        }

}

// create function to free the memory space of the matrix when finished
void dealloc_matrix(int_matrix *m) // don't need to pass nrows here as arg - attached to m now (from when created in initialise_matrix)
{
	int i;
        for (i = 0; i < (*m).nrows; ++i) {
                free((*m).data[i]);
        }
        free((*m).data);
}

// fully guard against out of bounds errors
void set_element(int data, int row, int col, int_matrix *m)
{
	if (row < (*m).nrows) {
		if (col < (*m).ncols) {
			(*m).data[row][col] = data;
		}
	}
};

// get element - return int from given matrix coords
int get_element(int row, int col, int_matrix *m)
{
	int data;
	if (row < (*m).nrows) {
                if (col < (*m).ncols) {
			data = (*m).data[row][col];
		}
	}
	return data;
}	

int main(void)
{
	/*
	int i;
	int_matrix m;

	// we want 8 rows and 5 columns
	
	// see notes for explanation

	// calloc (&malloc) give us a block of data of specified size
	m.data = calloc(8, sizeof(int*)); // will give us a pointer to 8 blocks which are each the size of integer pointers
	// data is a pointer that points to a vector of pointers

	// that vector of pointers points to the ints in the columns:
	for (i = 0; i < 8; ++i) {
		m.data[i] = calloc(5, sizeof(int));
	}
	*/


	// make the same as above but as a function - not hard coded

        int_matrix m;
        
	// we want 8 rows and 5 columns
	initialise_matrix(8, 5, &m);

	m.data[0][0] = 1; // assign first element of first row to 1
	set_element(1, 0, 0, &m); // does same as above w custom function

	int result;
	result = get_element(0, 0, &m);
	printf("The value in row 0, col 0 of matrix m: %i\n", result);

	set_element(500, 0, 0, &m); // change val at [0][0] to 500
	printf("The value in row 0, col 0 of matrix m: %i\n", get_element(0,0,&m));


	dealloc_matrix(&m); // deallocate the matrix memory, ie free it

	return 0;
}
