#include <stdio.h>

void print_site_names(char* site_names[])
{
    int i = 0;
    
    for (i = 0; i < 6; ++i) {
        printf("%s\n", site_names[i]);
    }
}

int main(void)
{
	// pointers to arrays
	int site_populations[150] = {0}; // Initialise all members to 0
	int *populations_ptr = NULL;

	populations_ptr = site_populations; // odn't need to use &
	// pointer points to first element of array
	*(populations_ptr + 4); // value of 5th element of array
	
	// to set pointer to another value in array:
	populations_ptr = &site_populations[4];
	// or using pointer arithmetic:
	populations_ptr = site_populations;
	populations_ptr = populations_ptr + 4;

	*populations_ptr; // dereferences the fifth element of site_populations


	// array of pointers
	//  (useful for working w large memory objects like trees, linked lists, etc)
	char *site_names[] = {"Parking lot",
			 "Cricket lawn",
			 "Manor house",
			 "Silwood Bottom",
			 "The Reactor",
			 "Japanese Garden",
			 };
	// basically array of strings, can index each element and treat as a string:
	print_site_names(site_names);

	return 0;
}
