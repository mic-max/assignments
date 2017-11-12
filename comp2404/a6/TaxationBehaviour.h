#ifndef TAXATIONBEHAVIOUR_H
#define TAXATIONBEHAVIOUR_H

class TaxationBehaviour {
	public:
		virtual float computeTax(float) const = 0;
};

#endif