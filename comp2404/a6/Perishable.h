#ifndef PERISHABLE_H
#define PERISHABLE_H

#include "ExpirationBehaviour.h"

class Perishable : public ExpirationBehaviour {
	public:
		virtual Date computeExpDate(Date*, int);
};

#endif