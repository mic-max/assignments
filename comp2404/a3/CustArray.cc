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

#include <string>
#include <cstdlib>
using namespace std;
#include <iostream>

#include "CustArray.h"

CustArray::CustArray() {
	size = 0;
}

void CustArray::cleanup() {
	for(int i = 0; i < size; i++) {
		elements[i]->cleanup();
		delete elements[i];
	}
}

int CustArray::getSize() {
	return size;
}

bool CustArray::get(int index, Customer** cust) {
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

bool CustArray::getById(int id, Customer** cust) {
	for(int i = 0; i < size; i++) {
		if(elements[i]->getId() == id) {
			*cust = elements[i];
			return true;
		}
	}

	return false;
}