/* * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                 */
/*  Program:  Simple Inventory System              */
/*  Author:   Christine Laurendeau                 */
/*  Date:     28-JUN-2016                          */
/*                                                 */
/*  (c) 2016 Christine Laurendeau                  */
/*  All rights reserved.  Distribution and         */
/*  reposting, in part or in whole, without the    */
/*  written consent of the author, is illegal.     */
/*                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * */

/*
    User interface object to provide IO to the user of the program.
*/

#ifndef UI_H
#define UI_H

#include "ProdList.h"
#include "CustArray.h"
#include "OrderArray.h"

using namespace std;

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
		void printCustomers(CustArray&);
		void printOrders(OrderArray&);
		void pause();
	private:
		int readInt();
};

#endif