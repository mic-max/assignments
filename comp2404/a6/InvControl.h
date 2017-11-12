#ifndef INVCONTROL_H
#define INVCONTROL_H

#include "Store.h"
#include "UI.h"
#include "OrderServer.h"

class InvControl {
	public:
		InvControl();
		void launch(int, char*[]);
	private:
		Store store;
		UI view;
		OrderServer orderServer;
		void initProducts();
		void initCustomers();
		void processAdmin();
		void processCashier();
};

#endif