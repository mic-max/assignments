#ifndef ORDERARRAY_H
#define ORDERARRAY_H

#include "Order.h"

class OrderArray {
	public:
		OrderArray();
		~OrderArray();
		void add(Order*);
		void toString(string&) const;
	private:
		int size;
		Order* elements[MAX_ARR];
};

#endif