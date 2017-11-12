#ifndef NONTAXABLE_H
#define NONTAXABLE_H

#include "TaxationBehaviour.h"

class NonTaxable : public TaxationBehaviour {
	public:
		virtual float computeTax(float) const;
};

#endif