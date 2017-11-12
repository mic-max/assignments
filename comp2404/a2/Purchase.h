/*
	Represents a purchase.
*/

#ifndef PURCHASE_H
#define PURCHASE_H

class Purchase {
	public:
		Purchase(int);
		int getProductId();
		int getLifetimeUnits();
		void setLifetimeUnits(int);
	private:
		int productId;
		int lifetimeUnits;
};

#endif