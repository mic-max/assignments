#ifndef TAXABLE_H
#define TAXABLE_H

#include "TaxationBehaviour.h"

class Taxable : public TaxationBehaviour {
	public:
		virtual float computeTax(float) const;
};

#endif