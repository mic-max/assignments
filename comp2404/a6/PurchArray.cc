#include "PurchArray.h"

PurchArray::PurchArray() {
	size = 0;
}

PurchArray::~PurchArray() {
	for(int i = 0; i < size; i++)
		delete elements[i];
}

int PurchArray::getSize() const {
	return size;
}

Purchase* PurchArray::get(int index) const {
	if (index < 0 || index >= size)
		exit(1); // TODO handle by printing error in UI
	return elements[index];
}

void PurchArray::add(int prodId) {
	if (size >= MAX_ARR)
		return;

	Purchase* purch;
	if(getById(prodId, &purch))
		purch->setLifetimeUnits(purch->getLifetimeUnits() + 1);
	else
		elements[size++] = new Purchase(prodId);
}


bool PurchArray::getById(int id, Purchase** purch) const {
	for(int i = 0; i < size; i++) {
		if(elements[i]->getProductId() == id) {
			*purch = elements[i];
			return true;
		}
	}
	return false;
}

bool PurchArray::contains(int id) const {
	for(int i = 0; i < size; i++) {
		if(elements[i]->getProductId() == id)
			return true;
	}
	return false;
}

ostream& operator<<(ostream& out, PurchArray& arr) {
	if(arr.getSize() != 0) {
		out << "  ID     Units" << endl;
		out << "  --     -----" << endl;
		for(int i = 0; i < arr.getSize(); i++)
			out << *(arr.get(i)) << endl;
	}
	return out;
}