#include "Store.h"

Store::~Store() {
	list<Customer*>::iterator it;
	for(it = customers.begin(); it != customers.end(); ++it)
		delete *it;
	customers.clear();
}

ProdList& Store::getStock() {
	stock.reorg();
	return stock;
}

list<Customer*>& Store::getCustomers() {
	return customers;
}

void Store::addProd(Product* prod) {
	stock.add(prod);
}

void Store::addCust(Customer* cust) {
	customers.push_back(cust);
}

void Store::purchase(Customer* cust, Product* prod) {
	prod->setUnits(prod->getUnits() - 1);
	int pts = prod->getPrice();
	cust->setPoints(cust->getPoints() + pts);
	cust->purchase(prod->getId());
}