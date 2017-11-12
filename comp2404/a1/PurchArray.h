/*
	A collection of purchases.
*/

#ifndef PURCHARRAY_H
#define PURCHARRAY_H

#include "defs.h"
#include "Purchase.h"

class PurchArray {
	public:
		PurchArray();
		void add(int);
		Purchase& get(int);
		bool getById(int, Purchase*);
		bool contains(int);
		int getSize();
		void print();
	private:
		Purchase elements[MAX_ARR];
		int size;
};	

#endif