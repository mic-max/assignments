#include "Purchase.h"

Purchase::Purchase(int id) {
	productId = id;
	lifetimeUnits = 1;
}

int Purchase::getProductId() { return productId; }
int Purchase::getLifetimeUnits() { return lifetimeUnits; }

void Purchase::setLifetimeUnits(int u) { lifetimeUnits = u; }