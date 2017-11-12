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

#include <cstdlib>
#include "InvControl.h"
#include "Store.h"

InvControl::InvControl() {
	initProducts();
	initCustomers();
}

void InvControl::launch(int argc, char* argv[]) {
	if (argc != 2) {
		view.printUsageError();
		exit(1);
	}

	string option(argv[1]);

	if (option == "-a") {
		// Admin menu
		processAdmin();
	} else if (option == "-c") {
		// Cashier menu
		processCashier();
	} else {
		view.printUsageError();
		exit(1);
	}
}

void InvControl::processAdmin() {
	int choice;
	string prodName, prodSize;
	int prodUnits, prodId, amount;
	float prodPrice;

	while (1) {
		choice = -1;
		view.adminMenu(choice);
		if (choice == 1) {
			// add new product
			view.promptForStr("Product name", prodName);
			view.promptForStr("Product size", prodSize);
			view.promptForInt("# units", prodUnits);
			view.promptForFloat("Price", prodPrice);
			Product prod(prodName, prodSize, prodUnits, prodPrice);
			store.addProd(prod);
			view.pause();
		} else if (choice == 2) {
			// add inventory
			view.printError("Feature not implemented");
		} else if (choice == 3) {
			// print inventory
			view.printStock(store.getStock());
			view.pause();
		} else if (choice == 4) {
			// print customers
			view.printCustomers(store.getCustomers());
			view.pause();
		} else {
			break;
		}
	}
}

void InvControl::processCashier() {
	int choice;
	int prodId, custId;

	while (1) {
		view.cashierMenu(choice);
		if (choice == 1) {
			// purchases
			view.promptForInt("Please enter the customer id", custId);
			// verify real customer
			Customer& cust = store.getCustomers().getById(custId);
			int points = 0;
			float price = 0;
			while(1) {
				view.promptForInt("Please enter the product ids [0 to exit]", prodId);
				if(prodId == 0)
					break;
				// verify product exists
				Product& prod = store.getStock().getById(prodId);
				// verify there's at least 1 product in stock
				if(prod.getUnits() <= 0) {
					view.printError("That product is out of stock.");
					continue;
				}
				store.purchase(cust, prod);
			}
		} else if (choice == 2) {
			// return purchases
			view.printError("Feature not implemented");
		} else if (choice == MAGIC_NUM) {
			// print inventory and customers
			view.printStock(store.getStock());
			view.printCustomers(store.getCustomers());
			view.pause();
		} else {
			break;
		}
	}
}

void InvControl::initProducts() {
	/*
		This function is so ugly!  It's because we're using 
		statically allocated memory, instead of dynamically
		alloated.  Don't worry, we'll fix this in Assignment #2.
	*/

	Product prod01("Sudzzy Dish Soap", "1 L", 10, 3.99f);
	Product prod02("Peachy Laundry Soap", "2 L", 3, 8.99f);
	Product prod03("Daisy's Spicy Chili", "150 g", 5, 1.29f);
	Product prod04("Daisy's Maple Baked Beans", "220 g", 2, 2.49f);
	Product prod05("Marmaduke Hot Dogs", "12-pack", 4, 4.99f);
	Product prod06("Garfield Hamburger Patties", "900 g", 2, 11.99f);
	Product prod07("Chunky Munkey Ice Cream", "2 L", 1, 2.97f);
	Product prod08("It's Your Bday Chocolate Cake", "500 g", 0, 12.99f);
	Product prod09("Happy Baker's Hot dog buns", "12-pack", 5, 3.49f);
	Product prod10("Happy Baker's Hamburger buns", "8-pack", 8, 3.99f);
	Product prod11("Moo-cow 2% milk", "1 L", 7, 2.99f);
	Product prod12("Moo-cow 2% milk", "4 L", 3, 4.99f);
	Product prod13("Moo-cow 5% coffee cream", "250 ml", 4, 1.49f);
	Product prod14("Good Morning Granola Cereal", "400 g", 2, 5.49f);
	Product prod15("Lightening Bolt Instant Coffee", "150 g", 8, 4.99f);
	Product prod16("Lightening Bolt Decaf Coffee", "100 g", 2, 4.99f);
	Product prod17("Munchies BBQ Chips", "250 g", 7, 2.99f);
	Product prod18("Munchies Ketchup Chips", "250 g", 3, 2.99f);
	Product prod19("Dogbert Salted Chips", "210 g", 4, 1.99f);
	Product prod20("Dogbert Sweet and Spicy Popcorn", "180 g", 5, 2.29f);

	store.addProd(prod01);
	store.addProd(prod02);
	store.addProd(prod03);
	store.addProd(prod04);
	store.addProd(prod05);
	store.addProd(prod06);
	store.addProd(prod07);
	store.addProd(prod08);
	store.addProd(prod09);
	store.addProd(prod10);
	store.addProd(prod11);
	store.addProd(prod12);
	store.addProd(prod13);
	store.addProd(prod14);
	store.addProd(prod15);
	store.addProd(prod16);
	store.addProd(prod17);
	store.addProd(prod18);
	store.addProd(prod19);
	store.addProd(prod20);
}

void InvControl::initCustomers() {
	Customer cust01("Starbuck");
	Customer cust02("Apollo");
	Customer cust03("Boomer");
	Customer cust04("Athena");
	Customer cust05("Helo");
	Customer cust06("Crashdown");
	Customer cust07("Hotdog");
	Customer cust08("Kat");
	Customer cust09("Chuckles");
	Customer cust10("Racetrack");

	store.addCust(cust01);
	store.addCust(cust02);
	store.addCust(cust03);
	store.addCust(cust04);
	store.addCust(cust05);
	store.addCust(cust06);
	store.addCust(cust07);
	store.addCust(cust08);
	store.addCust(cust09);
	store.addCust(cust10);
}