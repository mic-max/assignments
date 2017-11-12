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
#include "Store.h"

ProdArray& Store::getStock()     { return stock; }
CustArray& Store::getCustomers() { return customers; }

void Store::addProd(Product& prod) {
  stock.add(prod);
}

void Store::addCust(Customer& cust) {
  customers.add(cust);
}
        
void Store::purchase(Customer& cust, Product& prod) {
    prod.setUnits(prod.getUnits() - 1);
    int pts = prod.getPrice();
    cust.setPoints(cust.getPoints() + pts);
    cust.purchase(prod.getId());
}