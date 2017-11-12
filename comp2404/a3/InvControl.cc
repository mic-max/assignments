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
			view.promptForStr("Product name", prodName);
			view.promptForStr("Product size", prodSize);
			view.promptForInt("# units", prodUnits);
			view.promptForFloat("Price", prodPrice);
			Product* prod = new Product(prodName, prodSize, prodUnits, prodPrice);
			store.addProd(prod);
			view.pause();
		} else if (choice == 2) {
			int id, units;
			while(1) {
				view.promptForInt("Enter the product id [0 to exit]: ", id);
				if(id == 0)
					break;
				view.promptForInt("Enter the number of units: ", units);
				// a Store::addStock(id, units) would be better
				Product* prod;
				bool res = store.getStock().find(id, &prod);

				if(res) {
					prod->setUnits(prod->getUnits() + units);		
				} else {
					view.printError("That product does not exist.");
				}
			}
		} else if (choice == 3) {
			// print inventory
			view.printStock(store.getStock());
			view.pause();
		} else if (choice == 4) {
			// print customers
			view.printCustomers(store.getCustomers());
			view.pause();
		} else if(choice == 5) {
			// remove product
			view.promptForInt("Enter the ID of a product to remove: ", prodId);
			Product* prod;
			bool res = store.getStock().find(prodId, &prod);

			if(res) {
				store.getStock().remove(prod);
			} else {
				view.printError("That Product does not exist.");
			}
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
			// purchase
			Customer* cust;
			while(true) {
				view.promptForInt("Please enter the customer id", custId);
				bool res = store.getCustomers().getById(custId, &cust);
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
				bool res = store.getStock().find(prodId, &prod);
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
			// return
			view.printError("Feature not implemented");
		} else if (choice == MAGIC_NUM) {
			view.printStock(store.getStock());
			view.printCustomers(store.getCustomers());
			view.pause();
		} else {
			break;
		}
	}
}

void InvControl::initProducts() {
	store.addProd(new Product("Peachy Laundry Soap", "2 L", 3, 8.99f));
	store.addProd(new Product("Daisy's Spicy Chili", "150 g", 5, 1.29f));
	store.addProd(new Product("Daisy's Maple Baked Beans", "220 g", 2, 2.49f));
	store.addProd(new Product("Marmaduke Hot Dogs", "12-pack", 4, 4.99f));
	store.addProd(new Product("Garfield Hamburger Patties", "900 g", 2, 11.99f));
	store.addProd(new Product("Chunky Munkey Ice Cream", "2 L", 1, 2.97f));
	store.addProd(new Product("It's Your Bday Chocolate Cake", "500 g", 0, 12.99f));
	store.addProd(new Product("Happy Baker's Hot dog buns", "12-pack", 5, 3.49f));
	store.addProd(new Product("Happy Baker's Hamburger buns", "8-pack", 8, 3.99f));
	store.addProd(new Product("Moo-cow 2% milk", "1 L", 7, 2.99f));
	store.addProd(new Product("Moo-cow 2% milk", "4 L", 3, 4.99f));
	store.addProd(new Product("Moo-cow 5% coffee cream", "250 ml", 4, 1.49f));
	store.addProd(new Product("Good Morning Granola Cereal", "400 g", 2, 5.49f));
	store.addProd(new Product("Lightening Bolt Instant Coffee", "150 g", 8, 4.99f));
	store.addProd(new Product("Lightening Bolt Decaf Coffee", "100 g", 2, 4.99f));
	store.addProd(new Product("Munchies BBQ Chips", "250 g", 7, 2.99f));
	store.addProd(new Product("Munchies Ketchup Chips", "250 g", 3, 2.99f));
	store.addProd(new Product("Dogbert Salted Chips", "210 g", 4, 1.99f));
	store.addProd(new Product("Dogbert Sweet and Spicy Popcorn", "180 g", 5, 2.29f));
	store.addProd(new Product("Sudzzy Dish Soap", "1 L", 10, 3.99f));
}

void InvControl::initCustomers() {
	store.addCust(new Customer("Starbuck"));
	store.addCust(new Customer("Apollo"));
	store.addCust(new Customer("Boomer"));
	store.addCust(new Customer("Athena"));
	store.addCust(new Customer("Helo"));
	store.addCust(new Customer("Crashdown"));
	store.addCust(new Customer("Hotdog"));
	store.addCust(new Customer("Kat"));
	store.addCust(new Customer("Chuckles"));
	store.addCust(new Customer("Racetrack"));
}