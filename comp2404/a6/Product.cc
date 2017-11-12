#include "Product.h"
#include <iomanip>

int Product::nextProdId = 5001;

Product::Product(string n, string s, int u, float p, int y, int m, int d, int ls)
: manufactured(y, m, d), expiry(y, m, d) {
	id = nextProdId++;
	name = n;
	size = s;
	units = (u > 0) ? u : 0;
	price = (p > 0) ? p : 0;
	lifespan = (ls > 0) ? ls : 0;
}

Product::~Product() {
	delete exp;
	delete tax;
}

int Product::getId() const {
	return id;
}

string Product::getName() const {
	return name;
}

string Product::getSize() const	{
	return size;
}

int Product::getUnits() const {
	return units;
}

float Product::getPrice() const {
	return price;
}

void Product::setUnits(int n) {
	units = n;
}

float Product::computeTax() const {
	return tax->computeTax(price);
}

void Product::computeExpDate() {
	expiry = exp->computeExpDate(&manufactured, lifespan);
}

ostream& operator<<(ostream& out, const Product& prod) {
	out << prod.getId() << setfill(' ') << setw(40);
	out << prod.getName() << setfill(' ') << setw(10);
	out << prod.getSize() << setfill(' ') << setw(4);
	out << prod.getUnits() << setfill(' ') << setw(6);
	out << "$" << fixed << setprecision(2) << setfill(' ') << prod.getPrice();
	return out;
}