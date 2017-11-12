#ifndef NONPERISHABLE_H
#define NONPERISHABLE_H

#include "Product.h"

class NonPerishable : public virtual Product {
	public:
		NonPerishable();
		~NonPerishable();
		virtual void computeExpDate();
};

#endif