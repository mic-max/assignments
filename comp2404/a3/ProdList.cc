#include <sstream>
#include <iomanip>
#include "ProdList.h"

#include <iostream> // remove

using namespace std;

ProdList::ProdList(): head(0) {}
ProdList::~ProdList() {
	for(Node* curr = head; curr != 0; curr = curr->next) {
		delete curr->data;
		delete curr;
	}
}

void ProdList::add(Product* prod) {
	Node *tmp = new Node;
	tmp->data = prod;
	Node *curr = head;
	Node *prev = 0;

	while(curr != 0 && curr->data->getUnits() < prod->getUnits()) {
		prev = curr;
		curr = curr->next;
	}

	if(prev == 0) {
		if(curr) {
			curr->prev = tmp;
			tmp->next = curr;
		}
		head = tmp;
	} else {
		prev->next = tmp;
		if(curr)
			curr->prev = tmp;
		tmp->prev = prev;
		tmp->next = curr;
	}
}

void ProdList::remove(Product* prod) {
	Node *curr = head;
	Node *prev = 0;

	while(curr != 0 && curr->data != prod) {
		prev = curr;
		curr = curr->next;
	}

	// does this work for single element lists?
	if(curr->data == prod) {
		// found the node
		if(prev)
			prev->next = curr->next;
		if(curr->next)
			curr->next->prev = prev;
		delete curr->data;
		delete curr;
	}
}

// make getters and setters that call reorg

void ProdList::reorg() {
	if(head == 0 || head->next == 0)
		return;

	for(Node* i = head; i != 0; i = i->next) {
		for(Node* j = i->next; j != 0; j = j->next) {
			if(i->data->getUnits() < j->data->getUnits()) {
				Node* tmp = i;
				i = j;
				j = i;
			}
		}
	}
}

bool ProdList::find(int id, Product** prod) {
	for(Node* curr = head; curr != 0; curr = curr->next) {
		if(curr->data->getId() == id) {
			*prod = curr->data;
			return true;
		}
	}

	return false;
}

void ProdList::toString(string& strOut) {
	stringstream ss;
	ss << "STOCK:" << endl << endl;
	ss << " ID                                     Name      Size Qty     Price" << endl;
	ss << " --                                     ----      ---- ---     -----" << endl;

	Node* curr = head;
	Node* prev = 0;

	while(curr != 0) {
		Product* prod = curr->data;

		// overload operator<<(stringstream, Product)
		ss << prod->getId() << setfill(' ') << setw(40);
		ss << prod->getName()<< setfill(' ') << setw(10);
		ss << prod->getSize() << setfill(' ') << setw(4);
		ss << prod->getUnits() << setfill(' ') << setw(6);
		ss << "$" << fixed << setprecision(2) << setfill(' ') << prod->getPrice();
		ss << endl;

		prev = curr;
		curr = curr->next;
	}
	ss << endl;

	while(prev != 0) {
		Product* prod = prev->data;

		ss << prod->getId() << setfill(' ') << setw(40);
		ss << prod->getName()<< setfill(' ') << setw(10);
		ss << prod->getSize() << setfill(' ') << setw(4);
		ss << prod->getUnits() << setfill(' ') << setw(6);
		ss << "$" << fixed << setprecision(2) << setfill(' ') << prod->getPrice();
		ss << endl;
		
		curr = prev;
		prev = prev->prev;
	}

	strOut = ss.str();
}