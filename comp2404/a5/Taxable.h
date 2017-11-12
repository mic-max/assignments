#ifndef TAXABLE_H
#define TAXABLE_H

#include "Product.h"

class Taxable : public virtual Product {
	public:
		Taxable();
		~Taxable();
		virtual float computeTax() const;
};

#endif