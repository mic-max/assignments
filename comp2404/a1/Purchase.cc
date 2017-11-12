#include "Purchase.h"

Purchase::Purchase(int id, int u) {
	productId = id;
	lifetimeUnits = (u > 0) ? u : 0;
}

int Purchase::getProductId() { return productId; }
int Purchase::getLifetimeUnits() { return lifetimeUnits; }

void Purchase::setLifetimeUnits(int u) { lifetimeUnits = u; }