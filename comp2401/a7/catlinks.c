#include "a7Defs.h"

int main() {
	CatListType *cats = NULL;

	printf("# Starting to read cat data\n");
	initAllCats(&cats);
	printf("# Finished reading cat data\n");

	printf("# Starting to print cat data\n");
	printCats(&cats);
	printf("# Finished printing cat data\n");

	printf("# Starting to free cat data\n");
	freeCats(&cats);
	printf("# Finished freeing cat data\n");

	return 0;
}
/*
	Function: initAllCats
	 Purpose: dynamically initializes a cat list
	     out: cats
*/
void initAllCats(CatListType **cats) {
	// initialize cats by dyno allocating the linked list structure and init fields
	*cats = (CatListType *) malloc(sizeof(CatListType));
	(*cats)->head = NULL;
	(*cats)->tail = NULL;
	scanCats(cats);
}

/*
	Function: initCat
	 Purpose: dynamically initializes a cat structure
	      in: id
	      in: name
	      in: gender
	     out: cat

*/
void initCat(int id, char *name, GenderType gender, CatType **cat) {
	*cat = (CatType *) malloc(sizeof(CatType));
	(*cat)->id = id;
	strcpy((*cat)->name, name);
	(*cat)->gender = gender;
}

/*
	Function: scanCats
	 Purpose: reads in data from the user to fill a cats list
	in / out: cats
*/
void scanCats(CatListType **cats) {
	int id, gender;
	char name[MAX_STR];
	while(1) {
		printf(" Enter the cat's name [-1 to quit]:\n > ");
		readString(name);
		if(!strcmp(name, "-1"))
			return;

		printf(" Enter the cat's id:\n > ");
		readInt(&id);
		if(!validID(cats, id)) {
			printf(" Invalid id. Must be unique.\n");
			continue;
		}

		printf(" Enter the cat's gender [F = 0, M = 1]:\n > ");
		readInt(&gender);
		if(!validGender(gender)) {
			printf(" Invalid gender.\n");
			continue;
		}

		GenderType g = gender ? MALE : FEMALE;
		NodeType *node = (NodeType *) malloc(sizeof(NodeType));
		initCat(id, name, g, &node->data);
		insertCatAlpha(cats, node);
	}
	printf(" # Exiting, cats list is full\n");
}

void insertCatAlpha(CatListType **cats, NodeType *node) {
	NodeType *cur = (*cats)->head;
	NodeType *prev = NULL;
	char *name = node->data->name;
	if(cur == NULL) {
		(*cats)->head = node;
		(*cats)->tail = node;
	} else if(strcmp(cur->data->name, name) > 0) {
		node->next = (*cats)->head;
		(*cats)->head->prev = node;
		(*cats)->head = node;
	} else {
		while(cur != NULL) {
			// compare using lower case vals
			if(strcmp(cur->data->name, name) > 0) {
				node->prev = prev;
				node->next = cur;
				if(prev != NULL)
					prev->next = node;
				cur->prev = node;
				return;
			}
			// traverse
			prev = cur;
			cur = cur->next;
		}
		prev->next = node;
		node->prev = prev;
		(*cats)->tail = node;
	}
}

/*
	Function: printCats
	 Purpose: prints all cats in a CatArrType
	      in: cats
*/
void printCats(CatListType **cats) {
	NodeType *cur;

	printf(" Printing cats 'alphabetically'.\n");
	cur = (*cats)->head;
	while(cur != NULL) {
		printCat(cur->data);
		cur = cur->next;
	}

	printf(" Printing cats 'alphabetically' backwards.\n");
	cur = (*cats)->tail;
	while(cur != NULL) {
		printCat(cur->data);
		cur = cur->prev;
	}
}

/*
	Function: printCat
	 Purpose: prints attributes of a single cat
	      in: cat
*/
void printCat(CatType *cat) {
	printf("  Name: %s, ID: %d, Gender: %c\n",
		cat->name,
		cat->id,
		cat->gender ? 'F' : 'M'
	);
}

/*
	Function: freeCats
	 Purpose: free any dynamically allocated memory in cats
	     out: cats
*/
void freeCats(CatListType **cats) {
	NodeType *cur = (*cats)->head;
	NodeType *prev = NULL;
	while(cur != NULL) {
		prev = cur;
		free(cur->data);
		free(prev);
		cur = cur->next;
	}
	free(*cats);
}