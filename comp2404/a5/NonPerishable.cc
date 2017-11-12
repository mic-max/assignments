#include "NonPerishable.h"

NonPerishable::NonPerishable() {
	computeExpDate();
}

NonPerishable::~NonPerishable() {
}

void NonPerishable::computeExpDate() {
	expiry = manufactured + 730;
}