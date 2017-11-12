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

#include <cmath>
#include "Customer.h"

int Customer::nextCustId = 2001;

Customer::Customer(string n) {
	id = nextCustId++;
	name = n;
	points = 0;
}

void Customer::cleanup() {
	purchases.cleanup();
}

int		Customer::getId()			{ return id;     }
string	Customer::getName()			{ return name;   }
int		Customer::getPoints()		{ return points; }
void    Customer::setPoints(int pts){ points = pts; }
PurchArray* Customer::getPurchases() { return &purchases; }

void Customer::purchase(int prodId) {
	purchases.add(prodId);
}