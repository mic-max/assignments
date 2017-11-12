#include "Purchase.h"

Purchase::Purchase(int id) {
	productId = id;
	lifetimeUnits = 1;
}

int Purchase::getProductId() const {
	return productId;
}

int Purchase::getLifetimeUnits() const {
	return lifetimeUnits;
}

void Purchase::setLifetimeUnits(int u) {
	lifetimeUnits = u;
}

ostream& operator<<(ostream& out, const Purchase& purch) {
	out << "  " << purch.getProductId() << "      " << purch.getLifetimeUnits();
	return out;
}