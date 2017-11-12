#include <stdio.h>

#define MAX_SIZE 8

int scanFloats(float*, int, char);
float calculateFinal(float*, int, float*, int);
float sumFloats(float*, int);
char isBetween(float, float, float);
char allBetween(float*, int, float, float);

int main() {
	float scheme[MAX_SIZE];
	int schemeSize = 0;

	float grades[MAX_SIZE];
	int gradesSize = 0;

	printf("--- Input a negative float to end current input ---\n");
	printf("Enter some floats [Total Sum = 100] to serve as the evaluation scheme:\n");
	schemeSize = scanFloats(scheme, schemeSize, 1);

	// check if the scheme totals to 100%
	if(sumFloats(scheme, schemeSize) != 100) {
		printf("Invalid scheme.\n");
		return -1;
	}

	printf("Enter some floats [0, 100] to serve as a student’s grades:\n");
	gradesSize = scanFloats(grades, gradesSize, 0);

	// check for same amount of grades as scheme
	if(schemeSize != gradesSize) {
		printf("Invalid amount of grades.\n");
		return -2;
	}

	// check all grades are between[0, 100]
	if(!allBetween(grades, gradesSize, 0, 100)) {
		printf("Invalid grades.\n");
		return -3;
	}

	float final = calculateFinal(scheme, schemeSize, grades, gradesSize);
	printf("Final Grade: %.1f%%\n", final);

	return 0;
}

/*
	Function: scanFloats
	 Purpose: store input into the array depending on some criteria
	     out: arr
	      in: size
	      in: flag
	  return: size of array
*/
int scanFloats(float *arr, int size, char flag) {
	float num = -1;

	while(size < MAX_SIZE && scanf("%f", &num) && num >= 0) {
		// exists when size of scheme array is > 100
		if(flag && sumFloats(arr, size) > 100)
			break;
		arr[size++] = num;
	}

	// clears all extra input
	char c;
	while((c = getchar()) != '\n' && c != EOF);

	return size;
}

/*
	Function: calculateFinal
	 Purpose: to calculate the final using the scheme and student's grades
	      in: scheme
	      in: schemeSize
	      in: grades
	      in: gradesSize
	  return: sum of(product of(scheme[i], grades[i])) for all i 
*/
float calculateFinal(float *scheme, int schemeSize, float *grades, int gradesSize) {
	float final = 0;

	for(int i = 0; i < schemeSize; i++)
		final += scheme[i] * grades[i];

	return final / 100;
}

/*
	Function: isBetween
	 Purpose: checks if a num is inclusively between two values
	      in: num
	      in: min
	      in: max
	  return: non-0 if a num is inclusively between two values
*/
char isBetween(float num, float min, float max) {
	return min <= num && num <= max;
}

/*
	Function: allBetween
	 Purpose: checks if all floats in the array are between specified values
	      in: arr
	      in: size
	      in: min
	      in: max
	  return: if a float is not between min and max: 0, else: 1
*/
char allBetween(float *arr, int size, float min, float max) {
	for(int i = 0; i < size; i++) {
		if(!isBetween(arr[i], min, max))
			return 0;
	}

	return 1;
}

/*
	Function: sumFloats
	 Purpose: calculate the sum of an array of floats
	      in: arr
	      in: size
	  return: sum of all elements in the array
*/
float sumFloats(float* arr, int size) {
	float sum = 0;

	for(int i = 0; i < size; i++)
		sum += arr[i];

	return sum;
}