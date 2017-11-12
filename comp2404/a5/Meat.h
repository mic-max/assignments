#ifndef MEAT_H
#define MEAT_H

#include <string>
#include "Perishable.h"
#include "NonTaxable.h"
using namespace std;

class Meat : public Perishable, public NonTaxable {
	public:
		Meat(string, string, int, float, int, int, int, int);
		~Meat();
};

#endif