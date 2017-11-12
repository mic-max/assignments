#include "MiscGoods.h"
#include "NonTaxable.h"
#include "NonPerishable.h"

MiscGoods::MiscGoods(string n, string s, int u, float p, int y, int m, int d, int ls)
: Product(n, s, u, p, y, m, d, SHELF_LIFE) {
	exp = new NonPerishable();
	tax = new NonTaxable();
	Product::computeExpDate();
}