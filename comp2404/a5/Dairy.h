#ifndef DAIRY_H
#define DAIRY_H

#include "Perishable.h"
#include "NonTaxable.h"

using namespace std;

class Dairy : public Perishable, public NonTaxable {
	public:
		Dairy(string, string, int, float, int, int, int, int);
		~Dairy();
};

#endif