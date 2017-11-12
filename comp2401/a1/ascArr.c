#include <stdio.h>

#define MAX_SIZE 16

int addToArray(int*, int, int);
int remFromArray(int*, int, int);
void printArray(int*, int);

/*
   Function: main
	Purpose: to add integers entered by the user to an array in ascending order
	         print the array
	         remove integers eneterd by the user from an array
	         print the array
	 return: 0
*/
int main() {
	int array[MAX_SIZE];
	int size = 0;
	int num = -1;

	num = -1;
	printf("Enter a sequence of +integers to add (-1 to quit):\n");
	scanf("%d", &num);
	while(num >= 0) {
		size = addToArray(array, size, num);
		scanf("%d", &num);
	}
	printArray(array, size);

	num = -1;
	printf("Enter a sequence of +integers to remove (-1 to quit):\n");
	scanf("%d", &num);
	while(num >= 0) {
		size = remFromArray(array, size, num);
		scanf("%d", &num);
	}

	printArray(array, size);

	return 0;
}

/*
    Function: addToArray
     Purpose: to add a given number to an array in ascending order
         out: *arr
          in: size
          in: numToAdd
      return: the size of the array
*/
int addToArray(int *arr, int size, int numToAdd) {
	if(size == MAX_SIZE)
		return size;

	// find index to insert numToAdd at
	int i;
	for(i = 0; i < size; i++) {
		if(numToAdd < arr[i])
			break;
	}
	
	// shift memory over to the right
	for(int j = size; j >= i; j--)
		arr[j + 1] = arr[j];

	// insert num at i
	arr[i] = numToAdd;

	return size + 1;
}

/*
    Function: remFromArray
     Purpose: to remove a given number from an array if it exists
         out: *arr
          in: size
          in: numToGo
      return: the size of the array
*/
int remFromArray(int *arr, int size, int numToGo) {
	// find index of numToGo in arr
	int i;
	for(i = 0; i < size; i++) {
		if(arr[i] == numToGo)
			break;
	}

	if(i == size)
		return size;

	// shift memory over to the left
	for(int j = i; j < size; j++)
		arr[j] = arr[j + 1];

	return size - 1;
}

/*
    Function: printArray
     Purpose: to print all integers of the array on seperate lines
          in: *arr
          in: size
      return: void
*/
void printArray(int *arr, int size) {
	for(int i = 0; i < size; i++)
		printf("%d\n", arr[i]);
}