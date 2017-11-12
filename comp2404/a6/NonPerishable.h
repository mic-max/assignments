#ifndef NONPERISHABLE_H
#define NONPERISHABLE_H

#include "ExpirationBehaviour.h"
#include "defs.h"

class NonPerishable : public ExpirationBehaviour {
	public:
		virtual Date computeExpDate(Date*, int);
};

#endif