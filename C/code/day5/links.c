#include <stdio.h>
#include <stdlib.h>

struct ilink {
	int data; // the data it holds
	struct ilink *next; // a pointer to another ilink (called next)
	// struct ilink *back; // OPTIONAL - for a doubly-linked list
};
typedef struct ilink ilink;

void traverse_list(ilink *p) // continues traversing until NULL
{
	if (p != NULL) {
	        printf("%i\n", p->data); // print in pre-order
		traverse_list((*p).next); // recursive call - pass in pointer to next ilink
		// traverse_list(p->next); // same as above
		
		// printf("%i\n", p->data); // - post order
		// see notes for explanation of why this prints post-order (stack)
	}
}

int main(void)
{
	ilink i1;
	ilink i2;
	ilink i3;

	i1.data = 47;
	i2.data = 23;
	i3.data = 9;

	// connect these structs = link list
	i1.next = &i2;
	i2.next = &i3;
	i3.next = NULL;

	// traverse link list
	traverse_list(&i1);

	printf("Eliminate one element:\n");
	// i1.next = &i3; // remove i2 from list
	// OR
	i1.next = i1.next->next; // make i1 point at next, next item in list
	// didn't need to know that i3 is the one want to point at

	traverse_list(&i1);

	return 0;
}
