#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_ARR 64
#define MAX_STR 32

typedef enum { MALE, FEMALE } GenderType;

typedef struct {
	int id;
	char name[MAX_STR];
	GenderType gender;
} CatType;

typedef struct Node {
	CatType *data;
	struct Node *prev;
	struct Node *next;
} NodeType;

typedef struct {
	NodeType *head;
	NodeType *tail;
} CatListType;

void initCat(int, char*, GenderType, CatType**);
void initAllCats(CatListType**);
char validID(CatListType**, int);
char validGender(int);
char validYear(int);
char validMonth(int);
void readString(char*);
void readInt(int*);
void scanCats(CatListType**);
void printCats(CatListType**);
void printCat(CatType*);
void freeCats(CatListType**);
void insertCatAlpha(CatListType**, NodeType*);