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
    Represents a product.   
*/

#ifndef PRODUCT_H
#define PRODUCT_H

#include <string>
#include "Date.h"
using namespace std;

class Product {
	friend ostream& operator<<(ostream&, const Product&);
	public:
		Product(string = "Unknown", string = "Unknown", int = 0, float = 0.0f, int = 1997, int = 2, int = 2);
		~Product();
		int getId() const;
		string getName() const;
		string getSize() const;
		int getUnits() const;
		float getPrice() const;
		void setUnits(int);
		Date getExpiry() const;
		virtual float computeTax() const = 0;
		virtual void computeExpDate() = 0;
	protected:
		static int nextProdId;
		int id, units;
		float price;
		string name, size;
		Date manufactured;
		Date expiry;
};

#endif