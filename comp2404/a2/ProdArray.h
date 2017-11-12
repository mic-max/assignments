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
	A collection of Products.
*/

#ifndef PRODARRAY_H
#define PRODARRAY_H

#include "defs.h"
#include "Product.h"

class ProdArray {
	public:
		ProdArray();
		void add(Product*);
		bool get(int, Product*);
		bool getById(int, Product*);
		int getSize();
		void cleanup();
	private:
		Product* elements[MAX_ARR];
		int size;
};

#endif