#ifndef NONTAXABLE_H
#define NONTAXABLE_H

#include "Product.h"

class NonTaxable : public virtual Product {
	public:
		NonTaxable();
		~NonTaxable();
		virtual float computeTax() const;
};

#endif