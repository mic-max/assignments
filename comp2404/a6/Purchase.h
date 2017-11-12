#ifndef PURCHASE_H
#define PURCHASE_H

#include <ostream>
using namespace std;

class Purchase {
	friend ostream& operator<<(ostream&, const Purchase&);
	public:
		Purchase(int);
		int getProductId() const;
		int getLifetimeUnits() const;
		void setLifetimeUnits(int);
	private:
		int productId;
		int lifetimeUnits;
};

#endif