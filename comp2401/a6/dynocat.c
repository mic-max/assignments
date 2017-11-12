#include "a6Defs.h"

int main() {
	CatArrType cats;
	cats.size = 0;

	printf("# Starting to read cat data\n");
	scanCats(&cats);
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
	Function: initCat
	 Purpose: dynamically initializes a cat structure
	      in: id
	      in: name
	      in: gender
	      in: year
	      in: month
	     out: cat

*/
void initCat(int id, char *name, GenderType gender, int year, int month, CatType **cat) {
	*cat = (CatType *) malloc(sizeof(CatType));
	(*cat)->id = id;
	strcpy((*cat)->name, name);
	(*cat)->gender = gender;
	(*cat)->dob.year = year;
	(*cat)->dob.month = month;
}

/*
	Function: scanCats
	 Purpose: reads in data from the user to fill a cats array
	in / out: cats
*/
void scanCats(CatArrType *cats) {
	int id, gender, month, year;
	char name[MAX_STR];
	char begin[MAX_STR];
	char end[MAX_STR];
	strcpy(begin, " Enter the cat's ");
	strcpy(end, ":\n > ");
	while(cats->size < MAX_ARR) {
		printf(" Enter the cat's name [-1 to exit]:\n > ");
		readString(name);
		if(!strcmp(name, "-1"))
			return;

		printf("%sid%s", begin, end);
		readInt(&id);
		if(!validID(cats, id)) {
			printf(" Invalid id. Must be unique.\n");
			continue;
		}

		printf("%sgender [F = 0, M = 1]%s", begin, end);
		readInt(&gender);
		if(!validGender(gender)) {
			printf(" Invalid gender.\n");
			continue;
		}

		printf("%sbirth year%s", begin, end);
		readInt(&year);
		if(!validYear(year)) {
			printf(" Invalid year. Positive years only.\n");
			continue;
		}

		printf("%sbirth month%s", begin, end);
		readInt(&month);
		if(!validMonth(month)) {
			printf(" Invalid month. Ex: [1 => Jan, 2 => Feb, 3 => Mar, ...]\n");
			continue;
		}

		GenderType g = gender ? MALE : FEMALE;
		initCat(id, name, g, year, month, &cats->elements[cats->size]);
		cats->size++;
	}
	printf(" # Exiting, cats array is full\n");
}

/*
	Function: printCats
	 Purpose: prints all cats in a CatArrType
	      in: cats
*/
void printCats(CatArrType *cats) {
	for(int i = 0; i < cats->size; i++) {
		CatType *cat = cats->elements[i];
		printf(" Cat #%d\n", i + 1);
		printf("  Name: %s, ID: %d, Gender: %c, Birth: %d/%d\n",
			cat->name,
			cat->id,
			cat->gender ? 'F' : 'M',
			cat->dob.year,
			cat->dob.month);
	}
}

/*
	Function: freeCats
	 Purpose: free any dynamically allocated memory in cats
	     out: cats
*/
void freeCats(CatArrType *cats) {
	for(int i = 0; i < cats->size; i++)
		free(cats->elements[i]);
}

/*
	Function: validID
	 Purpose: to see if the input is a valid id
*/
char validID(CatArrType *cats, int id) {
	for(int i = 0; i < cats->size; i++) {
		if(cats->elements[i]->id == id)
			return 0;
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