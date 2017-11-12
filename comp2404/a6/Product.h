#ifndef PRODUCT_H
#define PRODUCT_H

#include "TaxationBehaviour.h"
#include "ExpirationBehaviour.h"

class Product {
	friend ostream& operator<<(ostream&, const Product&);
	public:
		Product(string = "Unknown", string = "Unknown", int = 0, float = 0.0f, int = 1997, int = 2, int = 2, int = 730);
		~Product();
		int getId() const;
		string getName() const;
		string getSize() const;
		int getUnits() const;
		float getPrice() const;
		void setUnits(int);
		virtual float computeTax() const;
		virtual void computeExpDate();
	protected:
		static int nextProdId;
		int id, units, lifespan;
		float price;
		string name, size;
		Date manufactured, expiry;

		TaxationBehaviour* tax;
		ExpirationBehaviour* exp;
};

#endif