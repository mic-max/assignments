#include <stdio.h>
#include <string.h>

#define MAX_ARR 64
#define MAX_STR 32

typedef struct {
	char code[MAX_STR];
	int grade;
} CourseType;

typedef struct {
	CourseType elements[MAX_ARR];
	int size;
} CourseArrType;

typedef struct {
	char name[MAX_STR];
	char id[MAX_STR];
	CourseArrType courses;
	float gpa;
} StudentType;

void readString(char*);
void readInt(int*);

void scanStudents(StudentType*, int*);
void scanCourses(CourseArrType*);

void initStudent(char*, char*, StudentType*);
void initCourse(char*, int, CourseType*);

void printStudent(StudentType*);
void printCourse(CourseType*);
void printAll(StudentType*, int);

void calculateGPA(StudentType*);
char validGrade(int);

int main() {
	int stuSize = 0;
	StudentType stu[MAX_ARR];

	printf("# Starting to read student data\n");
	scanStudents(stu, &stuSize);
	printf("# Finished reading student data\n");

	printf("# Starting to print student data\n");
	printAll(stu, stuSize);
	printf("# Finished printing student data\n");

	return 0;
}

/*
	Function: printAll
	 Purpose: prints all information of the given StudentType array
	      in: stu
	      in: stuSize
*/
void printAll(StudentType *stu, int stuSize) {
	for(int i = 0; i < stuSize; i++) {
		printf("Student #%d\n", i + 1);
		printStudent(&stu[i]);
	}
}

/*
	Function: printStudent
	 Purpose: prints all information of the given StudentType
	      in: stu
*/
void printStudent(StudentType *stu) {
	printf(" Name: %s\n ID: %s\n GPA: %.2f\n", stu->name, stu->id, stu->gpa);
	printf("  Courses Size = %d\n", stu->courses.size);
	for(int i = 0; i < stu->courses.size; i++) {
		printf("  Course #%d\n", i + 1);
		printCourse(&stu->courses.elements[i]);
	}
}

/*
	Function: printCourse
	 Purpose: prints all information of the given course
	      in: course
*/
void printCourse(CourseType *course) {
	printf("   Code: %s\n   Grade: %d\n", course->code, course->grade);
}

/*
	Function: initStudent
	 Purpose: initialize a StudentType struct
	      in: name
	      in: id
	     out: stu
*/
void initStudent(char *name, char *id, StudentType *stu) {
	strcpy(stu->name, name);
	strcpy(stu->id, id);
}

/*
	Function: initCourse
	 Purpose: initialize a CourseType struct
	      in: code
	      in: grade
	     out: course
*/
void initCourse(char *code, int grade, CourseType *course) {
	strcpy(course->code, code);
	course->grade = grade;
}

/*
	Function: scanStudents
	 Purpose: reads data from input to create students
	     out: stu
	  in/out: stuSize
*/
void scanStudents(StudentType* stu, int* stuSize) {
	char name[MAX_STR];
	char id[MAX_STR];
	while(*stuSize < MAX_ARR) {
		printf("Enter the student's name [-1 to exit]:\n> ");
		readString(name);
		if(!strcmp(name, "-1"))
			return;

		printf("Enter the student's id:\n> ");
		readString(id);
		initStudent(name, id, &stu[*stuSize]);

		printf(" # Starting to read course data\n");
		scanCourses(&stu[*stuSize].courses);
		calculateGPA(&stu[*stuSize]);
		printf(" # Finished reading course data\n");
		*(stuSize) += 1;
	}
	printf("# Exiting, student array is full\n");
}

/*
	Function: scanCourses
	 Purpose: reads data from input to create courses for a given student
	in / out: course
*/
void scanCourses(CourseArrType *course) {
	char code[MAX_STR];
	int grade;
	course->size = 0;
	
	while(course->size < MAX_ARR) {
		printf(" Enter the course code [-1 to exit]:\n > ");
		readString(code);
		if(!strcmp(code, "-1"))
			return;

		printf(" Enter the student's grade in this course:\n > ");
		readInt(&grade);
		if(!validGrade(grade)) {
			printf(" Invalid grade.\n");
			continue;
		}
		initCourse(code, grade, &course->elements[course->size]);
		course->size++;
	}
	printf(" # Exiting, course array is full\n");
}

/*
	Function: calculateGPA
	 Purpose: to take the average of a student's courses and set their gpa
	in / out: stu
*/
void calculateGPA(StudentType *stu) {
	float gpa = 0;
	for(int i = 0; i < stu->courses.size; i++) {
		gpa += stu->courses.elements[i].grade;
	}
	if(stu->courses.size != 0)
		stu->gpa = gpa / stu->courses.size;
	else
		stu->gpa = 0;
}

/*
	Function: validGrade
	 Purpose: return a char indicating if the grade is valid [0, 100]
	      in: grade
*/
char validGrade(int grade) {
	if(grade < 0 || 100 < grade)
		return 0;
	return 1;
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
	tmpStr[strlen(tmpStr)-1] = '\0';
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