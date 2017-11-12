#include "CoffeeTea.h"
#include "Taxable.h"
#include "NonPerishable.h"

CoffeeTea::CoffeeTea(string n, string s, int u, float p, int y, int m, int d, int ls)
: Product(n, s, u, p, y, m, d, SHELF_LIFE) {
	exp = new NonPerishable();
	tax = new Taxable();
	Product::computeExpDate();
}