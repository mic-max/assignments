#ifndef ORDERSERVER_H
#define ORDERSERVER_H

#include "OrderArray.h"

class OrderServer {
	public:
		OrderServer();
		~OrderServer();
		void update(Order*);
		void retrieve(OrderArray&);
	private:
		OrderArray orders;
};

#endif