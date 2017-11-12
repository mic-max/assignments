#include "Bakery.h"
#include "Taxable.h"
#include "Perishable.h"

Bakery::Bakery(string n, string s, int u, float p, int y, int m, int d, int ls)
: Product(n, s, u, p, y, m, d, ls) {
	exp = new Perishable();
	tax = new Taxable();
	Product::computeExpDate();
}