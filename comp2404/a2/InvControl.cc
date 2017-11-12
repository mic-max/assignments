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
			Product* prod = new Product(prodName, prodSize, prodUnits, prodPrice);
			store.addProd(prod);
			view.pause();
		} else if (choice == 2) {
			// add inventory
			int id, units;
			while(1) {
				view.promptForInt("Enter the product id: [0 to exit]", id);
				if(id == 0)
					break;
				view.promptForInt("Enter the number of units: ", units);
				// a Store::addStock(id, units) would be better
				Product* prod;
				bool res = store.getStock().getById(id, prod);
				if(!res) {
					view.printError("That product does not exist.");
					continue;
				}
				prod->setUnits(prod->getUnits() + units);
			}
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

			Customer* cust;
			while(true) {
				view.promptForInt("Please enter the customer id", custId);
				bool res = store.getCustomers().getById(custId, cust);
				// verify real customer
				if(!res)
					view.printError("This customer does not exist.");
				else
					break;
			}
			int points = 0;
			float price = 0;
			while(1) {
				view.promptForInt("Please enter the product ids [0 to exit]", prodId);
				if(prodId == 0)
					break;
				// verify product exists
				Product* prod;
				bool res = store.getStock().getById(prodId, prod);
				if(!res) {
					view.printError("That product does not exist.");
					continue;
				}
				// verify there's at least 1 product in stock
				if(prod->getUnits() < 1) {
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

	Product* prod01 = new Product("Sudzzy Dish Soap", "1 L", 10, 3.99f);
	Product* prod02 = new Product("Peachy Laundry Soap", "2 L", 3, 8.99f);
	Product* prod03 = new Product("Daisy's Spicy Chili", "150 g", 5, 1.29f);
	Product* prod04 = new Product("Daisy's Maple Baked Beans", "220 g", 2, 2.49f);
	Product* prod05 = new Product("Marmaduke Hot Dogs", "12-pack", 4, 4.99f);
	Product* prod06 = new Product("Garfield Hamburger Patties", "900 g", 2, 11.99f);
	Product* prod07 = new Product("Chunky Munkey Ice Cream", "2 L", 1, 2.97f);
	Product* prod08 = new Product("It's Your Bday Chocolate Cake", "500 g", 0, 12.99f);
	Product* prod09 = new Product("Happy Baker's Hot dog buns", "12-pack", 5, 3.49f);
	Product* prod10 = new Product("Happy Baker's Hamburger buns", "8-pack", 8, 3.99f);
	Product* prod11 = new Product("Moo-cow 2% milk", "1 L", 7, 2.99f);
	Product* prod12 = new Product("Moo-cow 2% milk", "4 L", 3, 4.99f);
	Product* prod13 = new Product("Moo-cow 5% coffee cream", "250 ml", 4, 1.49f);
	Product* prod14 = new Product("Good Morning Granola Cereal", "400 g", 2, 5.49f);
	Product* prod15 = new Product("Lightening Bolt Instant Coffee", "150 g", 8, 4.99f);
	Product* prod16 = new Product("Lightening Bolt Decaf Coffee", "100 g", 2, 4.99f);
	Product* prod17 = new Product("Munchies BBQ Chips", "250 g", 7, 2.99f);
	Product* prod18 = new Product("Munchies Ketchup Chips", "250 g", 3, 2.99f);
	Product* prod19 = new Product("Dogbert Salted Chips", "210 g", 4, 1.99f);
	Product* prod20 = new Product("Dogbert Sweet and Spicy Popcorn", "180 g", 5, 2.29f);

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
	Customer* cust01 = new Customer("Starbuck");
	Customer* cust02 = new Customer("Apollo");
	Customer* cust03 = new Customer("Boomer");
	Customer* cust04 = new Customer("Athena");
	Customer* cust05 = new Customer("Helo");
	Customer* cust06 = new Customer("Crashdown");
	Customer* cust07 = new Customer("Hotdog");
	Customer* cust08 = new Customer("Kat");
	Customer* cust09 = new Customer("Chuckles");
	Customer* cust10 = new Customer("Racetrack");

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