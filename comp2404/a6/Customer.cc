#include "Customer.h"
#include <iomanip>

int Customer::nextCustId = 2001;

Customer::Customer(string n) {
	id = nextCustId++;
	name = n;
	points = 0;
}

int Customer::getId() const {
	return id;
}

string Customer::getName() const {
	return name;
}

int Customer::getPoints() const {
	return points;
}

PurchArray* Customer::getPurchases() {
	return &purchases;
}

void Customer::setPoints(int pts) {
	points = pts;
}

void Customer::purchase(int prodId) {
	purchases.add(prodId);
}

ostream& operator<<(ostream& out, Customer& cust) {
	out << cust.getId() << setfill(' ') << setw(14);
	out << cust.getName()<< setfill(' ') << setw(10);
	out << cust.getPoints() << setfill(' ') << setw(4);
	out << endl << *(cust.getPurchases());
	return out;
}