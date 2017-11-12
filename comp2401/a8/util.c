#include "a8Defs.h"

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