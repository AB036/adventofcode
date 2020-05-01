#include <stdio.h>
#include <stdlib.h>

struct Node
{
	int data;
	struct Node* next;
};


int main()
{
	int arg = 312;
	
	struct Node* n = malloc(sizeof(struct Node));
	n->data = 0;
	n->next = n;
	
	
	for (int i = 1; i <= 2017; ++i)
	{
		for (int s = 0; s < arg; ++s)
		{
			n = n->next;
		}
		struct Node* nn = malloc(sizeof(struct Node));
		nn->next = n->next;
		nn->data = i;
		n->next = nn;
		n = nn;
	}
	
	printf("%d\n", n->next->data);
	
	for (int i = 0; i <= 2017; ++i)
	{
		struct Node* nn = n->next;
		free(n);
		n = nn;
	}
	
	int i = 0;
	int answer = 0;
	for (int size = 1; size <= 50000000 + 1; ++size)
	{
		i = (i + arg + 1) % size;
		if (i == 0)
			answer = size;
	}
	
	printf("%d\n", answer);
	
	return 0;
}
