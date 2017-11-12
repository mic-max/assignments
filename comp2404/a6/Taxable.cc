#include "Taxable.h"

float Taxable::computeTax(float price) const {
	return 0.13 * price;
}