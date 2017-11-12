#ifndef BAKERY_H
#define BAKERY_H

#include <string>
#include "Perishable.h"
#include "Taxable.h"
using namespace std;

class Bakery : public Perishable, public Taxable {
	public:
		Bakery(string, string, int, float, int, int, int, int);
		~Bakery();
};

#endif