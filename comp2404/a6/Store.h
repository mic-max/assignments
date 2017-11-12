#ifndef STORE_H
#define STORE_H

#include "ProdList.h"
#include "Product.h"
#include "Customer.h"

#include <list>

class Store {
	public:
		~Store();
		void addProd(Product*);
		void addCust(Customer*);
		ProdList& getStock();
		list<Customer*>& getCustomers();
		void purchase(Customer*, Product*);
		void customersToString(string&);
	private:
		ProdList stock;
		list<Customer*> customers;
};

#endif