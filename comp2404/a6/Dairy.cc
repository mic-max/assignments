#include "Dairy.h"
#include "NonTaxable.h"
#include "Perishable.h"

Dairy::Dairy(string n, string s, int u, float p, int y, int m, int d, int ls)
: Product(n, s, u, p, y, m, d, ls) {
	exp = new Perishable();
	tax = new NonTaxable();
	Product::computeExpDate();
}