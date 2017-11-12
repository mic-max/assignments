#include "Perishable.h"

Date Perishable::computeExpDate(Date* manufactured, int lifespan) {
	return (*manufactured) + lifespan;
}