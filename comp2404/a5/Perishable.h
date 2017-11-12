#ifndef PERISHABLE_H
#define PERISHABLE_H

#include "Product.h"

class Perishable : public virtual Product {
	public:
		Perishable(int);
		~Perishable();
		virtual void computeExpDate();
	protected:
		int lifespan;
};

#endif