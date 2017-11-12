#include <stdio.h>
#include <string.h>

#define MAX_ARR 64
#define MAX_STR 32

typedef enum {
	COMEDY, DRAMA, HORROR, SCIFI
} GenreType;

typedef struct {
	char title[MAX_STR];
	char director[MAX_STR];
	int year;
	GenreType genre;
} MovieType;

void initMovie(char*, char*, int, GenreType, MovieType*);
void printMovies(MovieType*, int);
void readString(char*);
void readInt(int*);

void printMovie(MovieType*);
void scanMovies(MovieType*, int*);

int main() {
	MovieType movies[MAX_ARR];
	int moviesSize = 0;

	printf("--- Starting to read movie data ---\n");
	scanMovies(movies, &moviesSize);
	printf("--- Finished reading movie data ---\n");
	
	printf("--- Starting to print all movies ---\n");
	printMovies(movies, moviesSize);
	printf("--- Finished printing all movies ---\n");

	return 0;
}

/*
	Function: initMovie
	 Purpose: to initialize a movie structure
	     out: movie
	      in: title
	      in: director
	      in: year
	      in: genre
*/
void initMovie(char *title, char *director, int year, GenreType genre, MovieType *movie) {
	strcpy(movie->title, title);
	strcpy(movie->director, director);
	movie->year = year;
	movie->genre = genre;
}

/*
	Function: printMovies
	 Purpose: print all movies in an array
	      in: movies
	      in: moviesSize
*/
void printMovies(MovieType *movies, int moviesSize) {
	for(int i = 0; i < moviesSize; i++) {
		printf("Movie #%d\n", i + 1);
		printMovie(&movies[i]);
	}
}

/*
	Function: readString
	 Purpose: reads a string from standard input
	     out: string read in from the user
	          (must be allocated in calling function)
*/
void readString(char *str) {
	char tmpStr[MAX_STR];
	fgets(tmpStr, sizeof(tmpStr), stdin);
	tmpStr[strlen(tmpStr) - 1] = '\0';
	strcpy(str, tmpStr);
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

/*
	Function: printMovie
	 Purpose: prints the information of a movie
	      in: MovieType
*/
void printMovie(MovieType *movie) {
	printf(" Title: %s\n", movie->title);
	printf(" Director: %s\n", movie->director);
	printf(" Year: %d\n", movie->year);
	printf(" Genre: ");
	switch(movie->genre) {
		case COMEDY:
			printf("Comedy\n");
			break;
		case DRAMA:
			printf("Drama\n");
			break;
		case HORROR:
			printf("Horror\n");
			break;
		case SCIFI:
			printf("Science Fiction\n");
			break;
	}
}

/*
	Function: scanMovies
	 Purpose: read in data from the user and fill a movies array
	     out: movies
	in / out: moviesSize
*/
void scanMovies(MovieType *movies, int *moviesSize) {
	char title[MAX_STR];
	char director[MAX_STR];
	int year, genre;

	while(*moviesSize < MAX_ARR) {
		printf("Enter the movie's title [-1 to exit]:\n> ");
		readString(title);
		if(!strcmp(title, "-1"))
			return;

		printf("Enter the movie's director:\n> ");
		readString(director);

		printf("Enter the movie's year:\n> ");
		readInt(&year);
		// only years in the common era allowed
		if(year < 0) {
			printf("Invalid year.\n");
			continue;
		}

		printf("Enter the movie's genre:\n%d. %s\n%d. %s\n%d. %s\n%d. %s\n> ",
			COMEDY, "Comedy",
			DRAMA, "Drama",
			HORROR, "Horror",
			SCIFI, "Science Fiction"
		);
		readInt(&genre);
		// error check if the genre isn't [0, 3]
		if(genre < 0 || 3 < genre) {
			printf("Invalid genre.\n");
			continue;
		}

		initMovie(title, director, year, genre, &movies[*moviesSize]);
		(*moviesSize)++;
	}
	printf("--- Exiting, movie array is full ---\n");
}