#include "ProdList.h"
#include <sstream>

ProdList::ProdList(): head(NULL) {}

ProdList::~ProdList() {
	Node* curr = head;

	while(curr != NULL) {
		Node* next = curr->next;
		delete curr->data;
		delete curr;
		curr = next;
	}

	head = NULL;
}

void ProdList::add(Product* prod) {
	Node *tmp = new Node;
	tmp->data = prod;
	tmp->next = NULL;
	tmp->prev = NULL;

	if(head == NULL) {
		head = tmp;
		return;
	}

	Node *prev = NULL;
	Node *curr = head;

	while(curr != NULL && curr->data->getUnits() < prod->getUnits()) {
		prev = curr;
		curr = curr->next;
	}

	if(curr == head) {
		curr->prev = tmp;
		tmp->next = curr;
		head = tmp;
	} else {
		tmp->prev = prev;
		prev->next = tmp;
		if(curr != NULL) {
			tmp->next = curr;
			curr->prev = tmp;
		}
	}
}

void ProdList::remove(Product* prod) {
	Node *curr = head;
	Node *prev = NULL;

	while(curr != NULL && curr->data != prod) {
		prev = curr;
		curr = curr->next;
	}

	if(curr != NULL) {
		if(prev != NULL)
			prev->next = curr->next;
		if(curr->next)
			curr->next->prev = prev;
		delete curr->data;
		delete curr;
	}
}

// TODO make getters and setters that call reorg

void ProdList::reorg() {
	for(Node* i = head; i != NULL; i = i->next) {
		for(Node* j = i->next; j != NULL; j = j->next) {
			if(i->data->getUnits() < j->data->getUnits()) {
				Node* tmp = i;
				i = j;
				j = i;
			}
		}
	}
}

bool ProdList::find(int id, Product** prod) const {
	for(Node* curr = head; curr != NULL; curr = curr->next) {
		if(curr->data->getId() == id) {
			*prod = curr->data;
			return true;
		}
	}

	return false;
}

void ProdList::toString(string& strOut) const {
	stringstream ss;
	ss << "STOCK:" << endl << endl;
	ss << " ID                                     Name      Size Qty     Price" << endl;
	ss << " --                                     ----      ---- ---     -----" << endl;

	Node* prev = NULL;
	for(Node* n = head; n != NULL; prev = n, n = n->next)
		ss << *(n->data) << endl;

	ss << endl;
	for(Node* n = prev; n != NULL; n = n->prev)
		ss << *(n->data) << endl;
	
	strOut = ss.str();
}