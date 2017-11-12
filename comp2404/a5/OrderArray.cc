#include <sstream>
#include "OrderArray.h"
using namespace std;

OrderArray::OrderArray() {
	size = 0;
}

OrderArray::~OrderArray() {
	// objects in the order->purchArray == objects in the customer->purchArray...
	// so cannot delete them both w/out throwing errors

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