#include "NonPerishable.h"

Date NonPerishable::computeExpDate(Date* manufactured, int lifespan) {
	return *(manufactured) + lifespan;
}