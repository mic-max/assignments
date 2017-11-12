#include "PurchArray.h"
#include <cstdlib>

using namespace std;

PurchArray::PurchArray() {
	size = 0;
}

int PurchArray::getSize() { return size; }

Purchase& PurchArray::get(int index) {
	if (index < 0 || index >= size)
		exit(1);
	return elements[index];
}

void PurchArray::add(int prodId) {
	if (size >= MAX_ARR)
		return;

	// if in array increase by 1, if not add 1
	Purchase* purch;
	if(getById(prodId, purch)) {
		purch->setLifetimeUnits(purch->getLifetimeUnits() + 1);
	} else {
		Purchase p(prodId);
		elements[size++] = p;
	}
}

bool PurchArray::getById(int id, Purchase* purch) {
	for(int i = 0; i < size; i++) {
		if(elements[i].getProductId() == id) {
			purch = &elements[i];
			return true;
		}
	}

	return false;
}

bool PurchArray::contains(int id) {
	for(int i = 0; i < size; i++) {
		if(elements[i].getProductId() == id)
			return true;
	}

	return false;
}