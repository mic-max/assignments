#include "OrderArray.h"
#include <sstream>

OrderArray::OrderArray() {
	size = 0;
}

OrderArray::~OrderArray() {
	for(int i = 0; i < size; i++)
	 	delete elements[i];
}

void OrderArray::add(Order* o) {
	if(size >= MAX_ARR)
		return;
	elements[size++] = o;
}

void OrderArray::toString(string& strOut) const {
	stringstream ss;
	ss << endl << "ORDERS:" << endl << endl;
	ss << " ID       BUYER       PRICE" << endl;
	ss << " --       -----       -----" << endl;
	for(int i = 0; i < size; i++)
		ss << *(elements[i]) << endl;

	strOut = ss.str();
}