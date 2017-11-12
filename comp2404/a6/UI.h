#ifndef UI_H
#define UI_H

#include "ProdList.h"
#include "OrderArray.h"
#include <list>

class UI {
	public:
		void mainMenu(int&);
		void adminMenu(int&);
		void cashierMenu(int&);
		void promptForInt(string, int&);
		void promptForStr(string, string&);
		void promptForFloat(string, float&);
		void printError(string);
		void printUsageError();
		void printStock(ProdList&);
		void printCustomers(list<Customer*>&);
		void printOrders(OrderArray&);
		void pause();
	private:
		int readInt();
};

#endif