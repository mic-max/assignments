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
    Represents a customer
*/

#ifndef CUSTOMER_H
#define CUSTOMER_H

#include <string>
#include "PurchArray.h"

using namespace std;

class Customer {
	friend ostream& operator<<(ostream&, Customer&);
	public:
		Customer(string = "Unknown");
		int getId() const;
		string getName() const;
		int getPoints() const;
		PurchArray* getPurchases();
		void purchase(int);
		void setPoints(int);
	protected:
		static int nextCustId;
		int id;
		string name;
		int points;
		PurchArray purchases;
};

#endif