#include "a7Defs.h"

/*
	Function: validID
	 Purpose: to see if the input is a valid id
	      in: cats
	      in: id
*/
char validID(CatListType **cats, int id) {
	NodeType *cur = (*cats)->head;
	while(cur != NULL) {
		if(cur->data->id == id)
			return 0;
		cur = cur->next;
	}
	return 1;
}

/*
	Function: validGender
	 Purpose: to see if the input is a valid gender
	      in: g
*/
char validGender(int g) {
	return g == 0 || g == 1;
}

/*
	Function: validYear
	 Purpose: to see if the input is a valid year
	      in: y
*/
char validYear(int y) {
	return 0 <= y;
}

/*
	Function: validMonth
	 Purpose: to see if the input is a valid month
	      in: m
*/
char validMonth(int m) {
	return 1 <= m && m <= 12;
}

/*
	Function: readString
	 Purpose: reads a string from standard input
	     out: string read in from the user
	          (must be allocated in calling function)
*/
void readString(char *str) {
	char beginStr[MAX_STR];
	fgets(beginStr, sizeof(beginStr), stdin);
	beginStr[strlen(beginStr) - 1] = '\0';
	strcpy(str, beginStr);
}

/*
	Function: readInt
	 Purpose: reads an integer from standard input
	     out: integer read in from the user
              (must be allocated in calling function)
*/
void readInt(int *x) {
	char str[MAX_STR];
	readString(str);
	sscanf(str, "%d", x);
}