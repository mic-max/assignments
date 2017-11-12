#ifndef MISCGOODS_H
#define MISCGOODS_H

#include <string>
#include "NonPerishable.h"
#include "NonTaxable.h"
using namespace std;

class MiscGoods : public NonPerishable, public NonTaxable {
	public:
		MiscGoods(string, string, int, float, int, int, int);
		~MiscGoods();
};

#endif