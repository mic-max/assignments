#include "Taxable.h"

Taxable::Taxable() {
}

Taxable::~Taxable() {
}

float Taxable::computeTax() const {
	return 0.13 * price;
}