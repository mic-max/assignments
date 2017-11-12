#ifndef COFFEETEA_H
#define COFFEETEA_H

#include <string>
#include "NonPerishable.h"
#include "Taxable.h"
using namespace std;

class CoffeeTea : public NonPerishable, public Taxable {
	public:
		CoffeeTea(string, string, int, float, int, int, int);
		~CoffeeTea();
};

#endif