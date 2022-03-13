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

int_matrix* new_int_matrix(int nrows, int ncols)
{
	int_matrix* mptr;

	mptr = calloc(1, sizeof(int_matrix));
	if (mptr != NULL) {
		initialise_matrix(nrows, ncols, mptr);
	}

	return mptr;
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

void delete_matrix(int_matrix *m)
{
	dealloc_matrix(m);
	free(m);
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
	if (row < (*m).nrows) {
                if (col < (*m).ncols) {
			return (*m).data[row][col];
		}
	}

	exit(EXIT_FAILURE);
}	
