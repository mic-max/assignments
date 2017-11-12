#include "Meat.h"

Meat::Meat(string n, string s, int u, float p, int y, int m , int d, int ls)
: Product(n, s, u, p, y, m, d), Perishable(ls) {

}

Meat::~Meat() {

}