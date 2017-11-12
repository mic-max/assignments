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

#include <sstream>
#include <iomanip>
#include "Product.h"

using namespace std;

int Product::nextProdId = 5001;

Product::Product(string n, string s, int u, float p) { 
	id = nextProdId++;
	name = n;
	size = s;
	units = (u > 0) ? u : 0;
	price = (p > 0) ? p : 0;
}

int Product::getId() const {
	return id;
}

string Product::getName() const {
	return name;
}

string Product::getSize() const	{
	return size;
}

int Product::getUnits() const {
	return units;
}

float Product::getPrice() const {
	return price;
}

void Product::setUnits(int n) {
	units = n;
}

ostream& operator<<(ostream& out, const Product& prod) {
	out << prod.getId() << setfill(' ') << setw(40);
	out << prod.getName()<< setfill(' ') << setw(10);
	out << prod.getSize() << setfill(' ') << setw(4);
	out << prod.getUnits() << setfill(' ') << setw(6);
	out << "$" << fixed << setprecision(2) << setfill(' ') << prod.getPrice();
	return out;
}