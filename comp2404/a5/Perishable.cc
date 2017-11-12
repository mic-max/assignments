#include "Perishable.h"

Perishable::Perishable(int ls) {
	lifespan = ls;
	computeExpDate();
}

Perishable::~Perishable() {
}

void Perishable::computeExpDate() {
	expiry = manufactured + lifespan;
}