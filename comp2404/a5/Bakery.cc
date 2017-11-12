#include "Bakery.h"

Bakery::Bakery(string n, string s, int u, float p, int y, int m , int d, int ls)
: Product(n, s, u, p, y, m, d), Perishable(ls) {

}

Bakery::~Bakery() {

}