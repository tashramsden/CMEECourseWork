#include <stdio.h>
#include <string.h>

// typedef char DNA_base_t; // alias for type so now can define things eg below and will be type char

struct site_data {
	float latitude;
	float longitude;
	float elevation;
	int observed_spp[500];
	int condition;
};

typedef struct site_data site_data; 
// now below in code can use just "site_data" in code rather than "struct site_data" every time

int main(void)
{
	// DNA_base_t sequence[100];

	site_data site1; // eg same as below now because of typedef above
	// could remove "struct" from "struct site_data" all below
	struct site_data site2;
	struct site_data site3;

	struct site_data mysites[3]; // same as above, because site_data knows type

	site1.latitude = 74.3444;
	printf("The latitude of site 1: %f\n", site1.latitude);
	printf("The longitude of site 1: %f\n", site1.longitude); // garbage - not initialised

	// Initialise a struct:
        // site1.latitude = 0.00; // etc, would take for ever to set all to 0
	memset(&site1, 0, sizeof(struct site_data)); // from string.h
	// above sets all vals in site1 to 0
	memset(&site2, 0, sizeof(struct site_data));
	memset(&site2, 0, sizeof(struct site_data));

	// for all sites at once (mysites)
	memset(mysites, 0, 3*sizeof(struct site_data));

	// pointers to structs
	struct site_data *site_data_ptr;
	site_data_ptr = &site1;
	(*site_data_ptr).latitude = 24.1; // or site_data_ptr->latitude=24.1;
        printf("The latitude of site 1 now: %f\n", site1.latitude);

	return 0;
}
