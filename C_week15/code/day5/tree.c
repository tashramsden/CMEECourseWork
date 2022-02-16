#include <stdio.h>
#include <stdlib.h>

struct node {
	struct node *left;
	struct node *right;
	struct node *parent;
	int index;
	char* name;

};
typedef struct node node;

void traverse_node(node *n)
{
	if (n != NULL) {
		traverse_node(n->left); // shorthand: (*n).left
		traverse_node(n->right); // once going to left returns, then go right
	}
}

int main(void)
{
	node n1;
	node n2;
	node n3;

	n1.left = n1.right = NULL; // n1 and n2 are tips
	n2.left = n2.right = NULL;
	n3.left = &n1;
	n3.right = &n2;

	traverse_node(&n3);

	return 0;
}
