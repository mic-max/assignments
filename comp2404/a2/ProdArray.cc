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

#include "ProdArray.h"

ProdArray::ProdArray() {
	size = 0;
}

void ProdArray::cleanup() {
	for(int i = 0; i < size; i++) {
		delete elements[i];
	}
}

int ProdArray::getSize() {
	return size;
}

bool ProdArray::get(int index, Product* prod) {
	if (index < 0 || index >= size)
		return false;

	prod = elements[index];
	return true;
}

void ProdArray::add(Product* prod) {
	if (size >= MAX_ARR)
		return;

	elements[size++] = prod;
}

bool ProdArray::getById(int id, Product* prod) {
	for(int i = 0; i < size; i++) {
		if(elements[i]->getId() == id)
			prod = elements[i];
			return true;
	}

	return false;
}