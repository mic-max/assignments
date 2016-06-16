#include "COMP1406W16A1.h"

float calculateYourFinalGrade(float avgT, float avgA, float markQ1, float markQ2, float markQ3, float markF) {
	float temp = markQ1 < markQ2 ? markQ1 : markQ2;
	float min = markQ3 < temp ? markQ3 : temp;
	return (avgT + markQ1 + markQ2 + markQ3 - min) * .1 + avgA * .3 + markF * .4;
}

bool didYouPassTheCourse(float avgT, float avgQ, float avgA, float markF) {
	return avgQ * .2 + markF * .4 >= 30 && avgQ * .2 + markF * .4 + avgT * .1 + avgA * .3 >= 50;
}

void printLetterGrade(float mark) {
	if(mark >= 80) {
		std::cout << 'A';
		if(mark >= 90)
			std::cout << '+';
		else if(mark <= 84)
			std::cout << '-';
	} else if(mark >= 50) {
		std::cout << (char) ((int) mark / -10 + 73);
		if((int) mark % 10 >= 7)
			std::cout << '+';
		else if((int) mark % 10 <= 2)
			std::cout << '-';
	} else
		std::cout << 'F';
	std::cout << std::endl;
}

float calculateClassStats(float marks[], int length) {
	float grade = 0;
	for(int i = 0; i < length; i++) {
		grade += marks[i];
		std::cout << marks[i] << ' ';
		printLetterGrade(marks[i]);
	}
	return grade / length;
}
