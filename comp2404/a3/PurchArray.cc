#include "PurchArray.h"
#include <cstdlib>
#include <iostream>
using namespace std;

PurchArray::PurchArray() {
	size = 0;
}

void PurchArray::cleanup() {
	for(int i = 0; i < size; i++) {
		delete elements[i];
	}
}

int PurchArray::getSize() { return size; }

Purchase* PurchArray::get(int index) {
	if (index < 0 || index >= size)
		exit(1);
	return elements[index];
}

void PurchArray::add(int prodId) {
	if (size >= MAX_ARR)
		return;

	// crashes when you've already purchased the product previously
	Purchase* purch;
	if(getById(prodId, &purch)) {
		// if found, increment units by 1
		purch->setLifetimeUnits(purch->getLifetimeUnits() + 1);
	} else {
		Purchase* p = new Purchase(prodId);
		elements[size++] = p;
	}
}


bool PurchArray::getById(int id, Purchase** purch) {
	for(int i = 0; i < size; i++) {
		if(elements[i]->getProductId() == id) {
			*purch = elements[i];
			return true;
		}
	}
	return false;
}

bool PurchArray::contains(int id) {
	for(int i = 0; i < size; i++) {
		if(elements[i]->getProductId() == id)
			return true;
	}
	return false;
}