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

#include <iostream>
#include <iomanip>
#include <string>
#include <sstream>
#include "UI.h"

using namespace std;

void UI::adminMenu(int& choice) {
	choice = -1;

	cout << endl << endl << endl << "                   INVENTORY MANAGEMENT SYSTEM ADMIN MENU" << endl << endl;
	cout << "          1. Add new product" << endl << endl;
	cout << "          2. Add more inventory" << endl << endl;
	cout << "          3. Print inventory" << endl << endl;
	cout << "          4. Print customers" << endl << endl;
	cout << "          5. Remove product" << endl << endl;
	cout << "          6. Print orders" << endl << endl;
	cout << "          0. Exit" << endl << endl;

	while (choice < 0 || choice > 6) {
		cout << "Enter your selection: ";
		choice = readInt();
	}
}

void UI::cashierMenu(int& choice) {
	choice = -1;

	cout << endl << endl << endl;
	cout << "                   INVENTORY MANAGEMENT SYSTEM CASHIER MENU" << endl << endl;
	cout << "          1. Product purchases" << endl << endl;
	cout << "          2. Product returns" << endl << endl;
	cout << "          0. Exit" << endl << endl;

	while (choice < 0 || choice > 2) {
		cout << "Enter your selection: ";
		choice = readInt();
		if (choice == MAGIC_NUM)
			return;
	}
}

void UI::printStock(ProdList& list) {
	string res;
	list.toString(res);
	cout << res;
}

void UI::printCustomers(CustArray& arr) {
	string res;
	arr.toString(res);
	cout << res;
}

void UI::printOrders(OrderArray& arr) {
	string res;
	arr.toString(res);
	cout << res;
}

void UI::printError(string err) {
	cout << endl << err << " -- press enter to continue...";
	cin.get();
}

void UI::printUsageError() {
	cout << endl << "Usage:  cushop OPTION" << endl << endl;
	cout << "        where OPTION is either: " << endl;
	cout << "              -a  Admin menu" << endl;
	cout << "              -c  Cashier menu" << endl << endl;
}

void UI::promptForInt(string prompt, int& num) {
	cout << prompt << ": ";
	num = readInt();
}

void UI::promptForStr(string prompt, string& str) {
	cout << prompt << ": ";
	getline(cin, str);
}

void UI::promptForFloat(string prompt, float& num) {
	string str;

	cout << prompt << ": ";
	getline(cin, str);

	stringstream ss(str);
	ss >> num;
}

int UI::readInt() {
	string str = "";
	int num = 0;

	getline(cin, str);
	stringstream ss(str);
	ss >> num;

	return num;
}

void UI::pause() {
	string str;

	cout << endl << endl << "Press enter to continue...";
	getline(cin, str);
}