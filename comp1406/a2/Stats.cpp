/*
    Student Name:     Michael Maxwell
    Student Number:   101006277
    References:       Lanthier,   M. (2016). COMP 1405 Notes. http://carleton.ca/culearn
                      Stroustrup, B. (2013). The C++ Programming Language.
*/

#ifndef STATS_CPP_INCLUDED
#define STATS_CPP_INCLUDED

#include "Stats.h"

void swap(int &a, int &b) {
    int t = a;
    a = b;
    b = t;
}

void bubbleSort(int data[], int dataSize) {
	for(int i = 1; i < dataSize; i++) {
		for(int j = 0; j < dataSize - i; j++) {
			if(data[j] > data[j + 1])
                  swap(data[j], data[j + 1]);
		}
	}
}

double trimmedMean(int data[], int dataSize, int outliers){
    // assumed: dataSize > outliers * 2
    int sum = 0;
    bubbleSort(data, dataSize);
    for(int i = outliers; i < dataSize - outliers; sum += data[i++]);
    return sum / (dataSize - outliers * 2);
}

#endif // STATS_CPP_INCLUDED
