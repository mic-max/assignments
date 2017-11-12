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
#include "CustArray.h"

CustArray::CustArray() {
	size = 0;
}

CustArray::~CustArray() {
	for(int i = 0; i < size; i++)
		delete elements[i];
}

int CustArray::getSize() const {
	return size;
}

bool CustArray::get(int index, Customer** cust) const {
	if (index < 0 || index >= size)
		return false;

	*cust = elements[index];
	return true;
}

void CustArray::add(Customer* cust) {
	if (size >= MAX_ARR)
		return;
	elements[size++] = cust;
}

bool CustArray::getById(int id, Customer** cust) const {
	for(int i = 0; i < size; i++) {
		if(elements[i]->getId() == id) {
			*cust = elements[i];
			return true;
		}
	}

	return false;
}

void CustArray::toString(string& strOut) const {
	stringstream ss;
	ss << endl << "CUSTOMERS:" << endl << endl;
	ss << " ID           Name      Points" << endl;
	ss << " --           ----      ------" << endl;
	for(int i = 0; i < size; i++)
		ss << *(elements[i]) << endl;

	strOut = ss.str();
}