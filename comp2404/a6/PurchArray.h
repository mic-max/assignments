#ifndef PURCHARRAY_H
#define PURCHARRAY_H

#include "Purchase.h"
#include "defs.h"

class PurchArray {
	friend std::ostream& operator<<(std::ostream&, PurchArray&);
	public:
		PurchArray();
		~PurchArray();
		void add(int);
		Purchase* get(int) const;
		bool getById(int, Purchase**) const;
		bool contains(int) const;
		int getSize() const;
	private:
		Purchase* elements[MAX_ARR];
		int size;
};	

#endif