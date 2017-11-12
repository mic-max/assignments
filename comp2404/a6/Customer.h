#ifndef CUSTOMER_H
#define CUSTOMER_H

#include "PurchArray.h"

class Customer {
	friend ostream& operator<<(ostream&, Customer&);
	public:
		Customer(string = "Unknown");
		int getId() const;
		string getName() const;
		int getPoints() const;
		PurchArray* getPurchases();
		void purchase(int);
		void setPoints(int);
	protected:
		static int nextCustId;
		int id;
		string name;
		int points;
		PurchArray purchases;
};

#endif