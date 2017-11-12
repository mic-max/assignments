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
	Stores a collection of Customers.
*/

#ifndef CUSTARRAY_H
#define CUSTARRAY_H

#include "defs.h"
#include "Customer.h"

class CustArray {
	public:
		CustArray();
		~CustArray();
		void add(Customer*);
		bool get(int, Customer**) const;
		bool getById(int, Customer**) const;
		int getSize() const;
		void toString(string&) const;
	private:
		Customer* elements[MAX_ARR];
		int size;
};

#endif