#ifndef ORDER_H
#define ORDER_H

#include "Customer.h"
#include "PurchArray.h"
#include "Product.h"

class Order {
	friend std::ostream& operator<<(std::ostream&, Order&);
	public:
		Order(Customer*);
		void add(Product*);
		PurchArray* getPurch();
		Customer* getCust() const;
		int getId() const;
		float getPrice();
	private:
		static int nextId;
		int id;
		Customer* buyer;
		PurchArray purchArray;
		float price;
};

#endif